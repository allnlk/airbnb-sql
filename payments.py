import csv
import random
from datetime import datetime, timedelta

# Configuration
NUM_RECORDS = 1000
OUTPUT_FILE = 'payments_data.csv'
USER_IDS = list(range(1, 101))  # Assuming you have users with IDs 1-100
PROCESSOR_IDS = [5, 10, 15, 20]  # IDs of accounting staff

# Payment data generators
payment_types = ['salary', 'bonus', 'reimbursement', 'other']
payment_methods = ['bank transfer', 'check', 'cash', 'digital wallet']
statuses = ['pending', 'completed', 'failed', 'cancelled']

def generate_payment_date():
    """Generate random date within last 2 years"""
    end_date = datetime.now()
    start_date = end_date - timedelta(days=730)
    random_days = random.randint(0, (end_date - start_date).days)
    return (start_date + timedelta(days=random_days)).strftime('%Y-%m-%d')

def generate_description(payment_type):
    """Generate description based on payment type"""
    if payment_type == 'salary':
        return f"Monthly salary payment"
    elif payment_type == 'bonus':
        return random.choice(["Performance bonus", "Year-end bonus", "Referral bonus"])
    elif payment_type == 'reimbursement':
        return random.choice(["Travel expenses", "Equipment purchase", "Training materials"])
    else:
        return "Miscellaneous payment"

def generate_transaction_reference():
    """Generate fake transaction reference"""
    return ''.join(random.choices('ABCDEFGHJKLMNPQRSTUVWXYZ23456789', k=10))

# Generate data
# ... (previous imports and configuration remain the same)

# Generate data
with open(OUTPUT_FILE, 'w', newline='') as csvfile:
    writer = csv.writer(csvfile)
    
    # Write header
    writer.writerow([
        'payment_id', 'user_id', 'payment_type', 'amount', 'payment_date',
        'payment_method', 'description', 'status', 'transaction_reference',
        'created_at', 'processed_by'
    ])
    
    # Write data rows
    for i in range(1, NUM_RECORDS + 1):
        payment_type = random.choice(payment_types)
        amount = round(random.uniform(50, 5000), 2)
        payment_date = generate_payment_date()
        created_at = (datetime.strptime(payment_date, '%Y-%m-%d') + 
                     timedelta(hours=random.randint(0, 23))).strftime('%Y-%m-%d %H:%M:%S')
        
        processed_by = random.choice(PROCESSOR_IDS) if random.random() > 0.2 else None
        
        writer.writerow([
            i,  # payment_id
            random.choice(USER_IDS),  # user_id
            payment_type,
            amount,
            payment_date,
            random.choice(payment_methods),  # payment_method
            generate_description(payment_type),  # description
            random.choices(statuses, weights=[10, 80, 5, 5])[0],  # status
            generate_transaction_reference() if random.random() > 0.3 else None,  # transaction_reference
            created_at,
            processed_by  # This will write as empty string when None
        ])

print(f"Generated {NUM_RECORDS} records in {OUTPUT_FILE}")