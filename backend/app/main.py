import os
import psycopg
from fastapi import FastAPI, HTTPException

app = FastAPI()
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