from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from sqlalchemy import select, func, inspect, text
from .database import Base, engine, get_db
from . import models as m, schemas as s
from .config import settings

Base.metadata.create_all(bind=engine)
# Lightweight additive migration for databases created by an earlier MVP version.
with engine.begin() as connection:
    inspector = inspect(engine)
    for table in ("buildings", "apartments"):
        if table in inspector.get_table_names():
            columns = {column["name"] for column in inspector.get_columns(table)}
            if "image_url" not in columns:
                connection.execute(text(f"ALTER TABLE {table} ADD COLUMN image_url VARCHAR(500) NOT NULL DEFAULT ''"))

app = FastAPI(title=settings.app_name, version="1.0.0",
              description="MVP API for apartment and syndic management in Morocco")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Restrict this list before production.
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def root():
    return {"app": settings.app_name, "docs": "/docs", "status": "running"}

@app.get("/health")
def health():
    return {"status": "ok"}

@app.post("/buildings", response_model=s.BuildingOut, status_code=201)
def create_building(payload: s.BuildingCreate, db: Session = Depends(get_db)):
    item = m.Building(**payload.model_dump())
    db.add(item); db.commit(); db.refresh(item)
    return item

@app.get("/buildings", response_model=list[s.BuildingOut])
def list_buildings(db: Session = Depends(get_db)):
    return db.scalars(select(m.Building).order_by(m.Building.id.desc())).all()

@app.get("/buildings/{building_id}", response_model=s.BuildingOut)
def get_building(building_id: int, db: Session = Depends(get_db)):
    item = db.get(m.Building, building_id)
    if not item: raise HTTPException(404, "Building not found")
    return item

@app.post("/apartments", response_model=s.ApartmentOut, status_code=201)
def create_apartment(payload: s.ApartmentCreate, db: Session = Depends(get_db)):
    if not db.get(m.Building, payload.building_id):
        raise HTTPException(404, "Building not found")
    item = m.Apartment(**payload.model_dump())
    db.add(item); db.commit(); db.refresh(item)
    return item

@app.get("/apartments", response_model=list[s.ApartmentOut])
def list_apartments(building_id: int | None = None, db: Session = Depends(get_db)):
    stmt = select(m.Apartment).order_by(m.Apartment.id.desc())
    if building_id is not None: stmt = stmt.where(m.Apartment.building_id == building_id)
    return db.scalars(stmt).all()

@app.post("/payments", response_model=s.PaymentOut, status_code=201)
def create_payment(payload: s.PaymentCreate, db: Session = Depends(get_db)):
    if not db.get(m.Apartment, payload.apartment_id):
        raise HTTPException(404, "Apartment not found")
    item = m.Payment(**payload.model_dump())
    db.add(item); db.commit(); db.refresh(item)
    return item

@app.get("/payments", response_model=list[s.PaymentOut])
def list_payments(apartment_id: int | None = None, db: Session = Depends(get_db)):
    stmt = select(m.Payment).order_by(m.Payment.paid_on.desc())
    if apartment_id is not None: stmt = stmt.where(m.Payment.apartment_id == apartment_id)
    return db.scalars(stmt).all()

@app.post("/expenses", response_model=s.ExpenseOut, status_code=201)
def create_expense(payload: s.ExpenseCreate, db: Session = Depends(get_db)):
    if not db.get(m.Building, payload.building_id):
        raise HTTPException(404, "Building not found")
    item = m.Expense(**payload.model_dump())
    db.add(item); db.commit(); db.refresh(item)
    return item

@app.get("/expenses", response_model=list[s.ExpenseOut])
def list_expenses(building_id: int | None = None, db: Session = Depends(get_db)):
    stmt = select(m.Expense).order_by(m.Expense.spent_on.desc())
    if building_id is not None: stmt = stmt.where(m.Expense.building_id == building_id)
    return db.scalars(stmt).all()

@app.post("/complaints", response_model=s.ComplaintOut, status_code=201)
def create_complaint(payload: s.ComplaintCreate, db: Session = Depends(get_db)):
    if not db.get(m.Building, payload.building_id):
        raise HTTPException(404, "Building not found")
    if payload.apartment_id and not db.get(m.Apartment, payload.apartment_id):
        raise HTTPException(404, "Apartment not found")
    item = m.Complaint(**payload.model_dump())
    db.add(item); db.commit(); db.refresh(item)
    return item

@app.get("/complaints", response_model=list[s.ComplaintOut])
def list_complaints(building_id: int | None = None, db: Session = Depends(get_db)):
    stmt = select(m.Complaint).order_by(m.Complaint.created_at.desc())
    if building_id is not None: stmt = stmt.where(m.Complaint.building_id == building_id)
    return db.scalars(stmt).all()

@app.patch("/complaints/{complaint_id}", response_model=s.ComplaintOut)
def update_complaint(complaint_id: int, payload: s.ComplaintUpdate, db: Session = Depends(get_db)):
    item = db.get(m.Complaint, complaint_id)
    if not item: raise HTTPException(404, "Complaint not found")
    allowed = {"new", "in_progress", "resolved", "rejected"}
    if payload.status not in allowed: raise HTTPException(400, f"Status must be one of {sorted(allowed)}")
    item.status = payload.status
    if payload.assigned_to is not None: item.assigned_to = payload.assigned_to
    db.commit(); db.refresh(item)
    return item

@app.get("/dashboard", response_model=s.DashboardOut)
def dashboard(building_id: int | None = None, db: Session = Depends(get_db)):
    apartment_stmt = select(func.count(m.Apartment.id))
    income_stmt = select(func.coalesce(func.sum(m.Payment.amount), 0.0)).join(m.Apartment)
    expense_stmt = select(func.coalesce(func.sum(m.Expense.amount), 0.0))
    complaints_stmt = select(func.count(m.Complaint.id)).where(m.Complaint.status.in_(["new", "in_progress"]))
    if building_id is not None:
        apartment_stmt = apartment_stmt.where(m.Apartment.building_id == building_id)
        income_stmt = income_stmt.where(m.Apartment.building_id == building_id)
        expense_stmt = expense_stmt.where(m.Expense.building_id == building_id)
        complaints_stmt = complaints_stmt.where(m.Complaint.building_id == building_id)
    income = float(db.scalar(income_stmt) or 0)
    expenses = float(db.scalar(expense_stmt) or 0)
    return s.DashboardOut(
        total_income=income, total_expenses=expenses, balance=income-expenses,
        apartments_count=int(db.scalar(apartment_stmt) or 0),
        open_complaints=int(db.scalar(complaints_stmt) or 0),
    )


@app.delete("/buildings/{item_id}", status_code=204)
def delete_building(item_id: int, db: Session = Depends(get_db)):
    item = db.get(m.Building, item_id)
    if not item: raise HTTPException(404, "Building not found")
    if item.apartments: raise HTTPException(409, "Delete or move apartments and their records first")
    db.delete(item); db.commit()

@app.delete("/apartments/{item_id}", status_code=204)
def delete_apartment(item_id: int, db: Session = Depends(get_db)):
    item = db.get(m.Apartment, item_id)
    if not item: raise HTTPException(404, "Apartment not found")
    if db.scalar(select(func.count(m.Payment.id)).where(m.Payment.apartment_id == item_id)):
        raise HTTPException(409, "Apartment has payment history and cannot be deleted")
    db.delete(item); db.commit()

@app.delete("/complaints/{item_id}", status_code=204)
def delete_complaint(item_id: int, db: Session = Depends(get_db)):
    item = db.get(m.Complaint, item_id)
    if not item: raise HTTPException(404, "Complaint not found")
    db.delete(item); db.commit()

@app.delete("/payments/{item_id}", status_code=204)
def delete_payment(item_id: int, db: Session = Depends(get_db)):
    item = db.get(m.Payment, item_id)
    if not item: raise HTTPException(404, "Payment not found")
    db.delete(item); db.commit()

@app.delete("/expenses/{item_id}", status_code=204)
def delete_expense(item_id: int, db: Session = Depends(get_db)):
    item = db.get(m.Expense, item_id)
    if not item: raise HTTPException(404, "Expense not found")
    db.delete(item); db.commit()
