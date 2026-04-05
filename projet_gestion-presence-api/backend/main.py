from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from pydantic import BaseModel
from sqlalchemy import create_engine, Column, Integer, String, ForeignKey, Date, Time, Enum
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session
from jose import JWTError, jwt
from passlib.context import CryptContext
from datetime import datetime, timedelta
from typing import List, Optional
import os

# --- CONFIGURATION ---
DATABASE_URL = os.getenv("DATABASE_URL", "mysql+pymysql://estc:estc2025@db/estc2025")
SECRET_KEY = os.getenv("JWT_SECRET", "estc_secret_key_2025")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="ESTC Presence API 2025")

# --- CONFIGURATION CORS (Nécessaire pour Flutter Web / Chrome) ---
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # Accepter toutes les origines (localhost, ips, etc)
    allow_credentials=True,
    allow_methods=["*"], # GET, POST, PUT, DELETE, etc.
    allow_headers=["*"],
)

# --- MODÈLES SQLALCHEMY ---

class Filiere(Base):
    __tablename__ = "Filiere"
    id_filiere = Column(Integer, primary_key=True, index=True)
    nom_filiere = Column(String(100))

class Etudiant(Base):
    __tablename__ = "Etudiant"
    id_etudiant = Column(Integer, primary_key=True, index=True)
    nom = Column(String(50))
    prenom = Column(String(50))
    email = Column(String(100), unique=True)
    password_hash = Column(String(255))
    id_filiere = Column(Integer, ForeignKey("Filiere.id_filiere"))

class Professeur(Base):
    __tablename__ = "Professeur"
    id_prof = Column(Integer, primary_key=True, index=True)
    nom = Column(String(50))
    prenom = Column(String(50))
    email = Column(String(100), unique=True)
    password_hash = Column(String(255))

class Module(Base):
    __tablename__ = "Module"
    id_module = Column(Integer, primary_key=True, index=True)
    nom_module = Column(String(100))

class Seance(Base):
    __tablename__ = "Seance"
    id_seance = Column(Integer, primary_key=True, index=True)
    date_seance = Column(Date)
    heure_debut = Column(Time)
    heure_fin = Column(Time)
    id_prof = Column(Integer, ForeignKey("Professeur.id_prof"))
    id_module = Column(Integer, ForeignKey("Module.id_module"))
    id_filiere = Column(Integer, ForeignKey("Filiere.id_filiere"))

class Presence(Base):
    __tablename__ = "Presence"
    id_presence = Column(Integer, primary_key=True, index=True)
    id_seance = Column(Integer, ForeignKey("Seance.id_seance", ondelete="CASCADE"))
    id_etudiant = Column(Integer, ForeignKey("Etudiant.id_etudiant", ondelete="CASCADE"))
    statut = Column(Enum('Present', 'Absent', 'Retard', 'Justifie'), default='Absent')
    commentaire = Column(String(500), nullable=True)

# --- DEPENDENCY ---
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# --- AUTH LOGIC ---
def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

# --- ROUTES ---

@app.post("/token")
async def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    prof = db.query(Professeur).filter(Professeur.email == form_data.username).first()
    if prof and form_data.password == "estc2025":
        access_token = create_access_token(data={"sub": prof.email, "role": "professeur"})
        return {"access_token": access_token, "token_type": "bearer"}
        
    etud = db.query(Etudiant).filter(Etudiant.email == form_data.username).first()
    if etud and form_data.password == "estc2025":
        access_token = create_access_token(data={"sub": etud.email, "role": "etudiant"})
        return {"access_token": access_token, "token_type": "bearer"}
        
    raise HTTPException(status_code=400, detail="Email ou mot de passe incorrect")

@app.get("/me")
async def read_users_me(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        email = payload.get("sub")
        role = payload.get("role", "professeur") # default to professeur for back-compat
    except JWTError:
        raise HTTPException(status_code=401, detail="Token invalide")
        
    if role == "professeur":
        user = db.query(Professeur).filter(Professeur.email == email).first()
    else:
        user = db.query(Etudiant).filter(Etudiant.email == email).first()
        
    if not user:
        raise HTTPException(status_code=404, detail="Utilisateur non trouvé")
        
    user_dict = {c.name: getattr(user, c.name) for c in user.__table__.columns}
    user_dict["role"] = role
    return user_dict

# --- CRUD FILIERES ---
@app.get("/filieres")
def read_filieres(db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)):
    return db.query(Filiere).all()

@app.post("/filieres")
def create_filiere(nom: str, db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)):
    new_f = Filiere(nom_filiere=nom)
    db.add(new_f)
    db.commit()
    return new_f

# --- CRUD ETUDIANTS ---
@app.get("/etudiants")
def read_etudiants(db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)):
    return db.query(Etudiant).all()

@app.post("/etudiants")
def create_etudiant(nom: str, prenom: str, id_filiere: int, db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)):
    new_e = Etudiant(nom=nom, prenom=prenom, id_filiere=id_filiere)
    db.add(new_e)
    db.commit()
    return new_e

@app.delete("/etudiants/{id}")
def delete_etudiant(id: int, db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)):
    e = db.query(Etudiant).filter(Etudiant.id_etudiant == id).first()
    if not e: raise HTTPException(status_code=404)
    db.delete(e)
    db.commit()
    return {"message": "Supprimé"}

# --- SEANCES & PRESENCES ---
@app.get("/seances")
def read_seances(db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)):
    # Returns all seances (joined with modules/filieres normally, but we return all models here)
    return db.query(Seance).all()

@app.get("/seances/me")
def read_my_seances(db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)):
    payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
    email = payload.get("sub")
    prof = db.query(Professeur).filter(Professeur.email == email).first()
    if prof:
        return db.query(Seance).filter(Seance.id_prof == prof.id_prof).all()
    return []

@app.get("/seances/{id_seance}/presence")
def get_presence(id_seance: int, db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)):
    return db.query(Presence).filter(Presence.id_seance == id_seance).all()

class PresenceUpdate(BaseModel):
    id_etudiant: int
    statut: str

@app.put("/seances/{id_seance}/presence")
def update_presence(id_seance: int, data: PresenceUpdate, db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)):
    p = db.query(Presence).filter(Presence.id_seance == id_seance, Presence.id_etudiant == data.id_etudiant).first()
    if p:
        p.statut = data.statut
    else:
        p = Presence(id_seance=id_seance, id_etudiant=data.id_etudiant, statut=data.statut)
        db.add(p)
    db.commit()
    db.refresh(p)
    return p

@app.get("/etudiants/me/presences")
def get_student_presences(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
    if payload.get("role") != "etudiant":
        raise HTTPException(status_code=403, detail="Accès réservé aux étudiants")
        
    email = payload.get("sub")
    etud = db.query(Etudiant).filter(Etudiant.email == email).first()
    if not etud:
        raise HTTPException(status_code=404, detail="Étudiant introuvable")

    presences = db.query(Presence, Seance, Module).join(Seance, Presence.id_seance == Seance.id_seance).join(Module, Seance.id_module == Module.id_module).filter(Presence.id_etudiant == etud.id_etudiant).all()
    
    result = []
    for p, s, m in presences:
        result.append({
            "id_presence": p.id_presence,
            "statut": p.statut,
            "date_seance": s.date_seance,
            "heure_debut": s.heure_debut,
            "heure_fin": s.heure_fin,
            "moduleNom": m.nom_module,
        })
    return result
