from datetime import date, datetime
from pydantic import BaseModel, ConfigDict, Field

class ORMModel(BaseModel):
    model_config = ConfigDict(from_attributes=True)

class BuildingCreate(BaseModel):
    name: str = Field(min_length=2, max_length=150)
    address: str = ""
    city: str = ""
    monthly_fee: float = Field(default=0, ge=0)
    image_url: str = ""

class BuildingOut(ORMModel):
    id: int
    name: str
    address: str
    city: str
    monthly_fee: float
    image_url: str

class ApartmentCreate(BaseModel):
    building_id: int
    number: str
    floor: int = 0
    owner_name: str = ""
    phone: str = ""
    image_url: str = ""

class ApartmentOut(ORMModel):
    id: int
    building_id: int
    number: str
    floor: int
    owner_name: str
    phone: str
    image_url: str

class PaymentCreate(BaseModel):
    apartment_id: int
    amount: float = Field(gt=0)
    paid_on: date = Field(default_factory=date.today)
    period: str = ""
    method: str = "cash"
    reference: str = ""
    note: str = ""

class PaymentOut(ORMModel):
    id: int
    apartment_id: int
    amount: float
    paid_on: date
    period: str
    method: str
    reference: str
    note: str

class ExpenseCreate(BaseModel):
    building_id: int
    title: str
    category: str = "other"
    amount: float = Field(gt=0)
    spent_on: date = Field(default_factory=date.today)
    supplier: str = ""
    invoice_ref: str = ""
    note: str = ""

class ExpenseOut(ORMModel):
    id: int
    building_id: int
    title: str
    category: str
    amount: float
    spent_on: date
    supplier: str
    invoice_ref: str
    note: str

class ComplaintCreate(BaseModel):
    building_id: int
    apartment_id: int | None = None
    title: str
    description: str = ""
    category: str = "general"
    assigned_to: str = ""

class ComplaintUpdate(BaseModel):
    status: str
    assigned_to: str | None = None

class ComplaintOut(ORMModel):
    id: int
    building_id: int
    apartment_id: int | None
    title: str
    description: str
    category: str
    status: str
    created_at: datetime
    assigned_to: str

class DashboardOut(BaseModel):
    total_income: float
    total_expenses: float
    balance: float
    apartments_count: int
    open_complaints: int
