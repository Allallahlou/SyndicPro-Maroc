# Database entities

- Building: building identity, address, city and default monthly fee.
- Apartment: apartment number, floor, owner and contact.
- Payment: apartment, amount, date, period and payment method.
- Expense: building, title, category, amount, supplier and invoice reference.
- Complaint: building, optional apartment, title, description, status and assignee.

The current schema is a starting point. Add user accounts, roles, ownership shares (tantièmes),
audit logs, attachments and migrations before production.
