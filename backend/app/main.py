import os
import psycopg
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI()

class User(BaseModel):
    sis_id: str
    first_name: str
    last_name: str
    email: str
    role: str
    building: str
    status: str

DATABASE_URL = os.getenv("DATABASE_URL")

@app.get("/health")
def health_check():
    try:
        with psycopg.connect(DATABASE_URL) as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT 1;")
        return {"status": "healthy", "database": "connected"}
    except Exception as e:
        raise HTTPException(status_code=503, detail=f"Database unreachable: {str(e)}")
    
@app.post("/user")
async def add_user(user_data: User):
    try:
        with psycopg.connect(DATABASE_URL) as conn:
            with conn.cursor() as cur:
                cur.execute(f"INSERT INTO users (sis_id, first_name, last_name, email, role, building, status) VALUES ({user_data.sis_id}, '{user_data.first_name}', '{user_data.last_name}', '{user_data.email}', '{user_data.role}', '{user_data.building}', '{user_data.status}'); ")
                return {"status": "success"}
    except Exception as e:
            raise HTTPException(status_code=503, detail=f"Database unreachable: {str(e)}")