from datetime import datetime, date
from sqlalchemy import String, Integer, Float, Date, DateTime, ForeignKey, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship
from .database import Base

class Building(Base):
    __tablename__ = "buildings"
    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String(150), index=True)
    address: Mapped[str] = mapped_column(String(250), default="")
    city: Mapped[str] = mapped_column(String(100), default="")
    image_url: Mapped[str] = mapped_column(String(500), default="")
    monthly_fee: Mapped[float] = mapped_column(Float, default=0)
    apartments: Mapped[list["Apartment"]] = relationship(back_populates="building", cascade="all, delete-orphan")

class Apartment(Base):
    __tablename__ = "apartments"
    id: Mapped[int] = mapped_column(primary_key=True)
    building_id: Mapped[int] = mapped_column(ForeignKey("buildings.id"), index=True)
    number: Mapped[str] = mapped_column(String(30))
    floor: Mapped[int] = mapped_column(Integer, default=0)
    owner_name: Mapped[str] = mapped_column(String(150), default="")
    phone: Mapped[str] = mapped_column(String(40), default="")
    image_url: Mapped[str] = mapped_column(String(500), default="")
    building: Mapped[Building] = relationship(back_populates="apartments")

class Payment(Base):
    __tablename__ = "payments"
    id: Mapped[int] = mapped_column(primary_key=True)
    apartment_id: Mapped[int] = mapped_column(ForeignKey("apartments.id"), index=True)
    amount: Mapped[float] = mapped_column(Float)
    paid_on: Mapped[date] = mapped_column(Date, default=date.today)
    period: Mapped[str] = mapped_column(String(20), default="")
    method: Mapped[str] = mapped_column(String(40), default="cash")
    reference: Mapped[str] = mapped_column(String(100), default="")
    note: Mapped[str] = mapped_column(Text, default="")

class Expense(Base):
    __tablename__ = "expenses"
    id: Mapped[int] = mapped_column(primary_key=True)
    building_id: Mapped[int] = mapped_column(ForeignKey("buildings.id"), index=True)
    title: Mapped[str] = mapped_column(String(150))
    category: Mapped[str] = mapped_column(String(80), default="other")
    amount: Mapped[float] = mapped_column(Float)
    spent_on: Mapped[date] = mapped_column(Date, default=date.today)
    supplier: Mapped[str] = mapped_column(String(150), default="")
    invoice_ref: Mapped[str] = mapped_column(String(100), default="")
    note: Mapped[str] = mapped_column(Text, default="")

class Complaint(Base):
    __tablename__ = "complaints"
    id: Mapped[int] = mapped_column(primary_key=True)
    building_id: Mapped[int] = mapped_column(ForeignKey("buildings.id"), index=True)
    apartment_id: Mapped[int | None] = mapped_column(ForeignKey("apartments.id"), nullable=True)
    title: Mapped[str] = mapped_column(String(160))
    description: Mapped[str] = mapped_column(Text, default="")
    category: Mapped[str] = mapped_column(String(80), default="general")
    status: Mapped[str] = mapped_column(String(30), default="new")
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    assigned_to: Mapped[str] = mapped_column(String(150), default="")
