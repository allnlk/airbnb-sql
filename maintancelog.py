import csv
import random
from datetime import datetime, timedelta

def load_ids_with_generated_ids(filename):
    with open(filename, 'r', encoding='utf-8') as f:
        reader = csv.reader(f)
        next(reader)  # skip header
        return list(range(1, sum(1 for _ in reader) + 1))


def random_date(start_days_ago=90, end_days_ago=0):
    days_ago = random.randint(end_days_ago, start_days_ago)
    return (datetime.now() - timedelta(days=days_ago)).strftime('%Y-%m-%d %H:%M:%S')

def generate_maintenance_logs(rooms, cars, limit=1000):
    logs = []
    maintenance_types = ['Electrical', 'Plumbing', 'Engine Check', 'Interior Cleaning', 'HVAC']
    descriptions = ['Routine check-up', 'Urgent repair', 'Scheduled maintenance', 'Customer-reported issue']
    technicians = ['TechCorp', 'FixItAll', 'AutoPro', 'RoomCare', 'HandyHub']
    statuses = ['scheduled', 'in progress', 'completed', 'cancelled']

    for _ in range(limit):
        is_room = random.random() < 0.5
        item_type = 'room' if is_room else 'car'
        item_id = random.choice(rooms if is_room else cars)

        start_date = random_date(90, 30)
        end_date = random_date(30, 0) if random.random() < 0.8 else None  

        log_entry = {
            'item_type': item_type,
            'item_id': item_id,
            'maintenance_type': random.choice(maintenance_types),
            'description': random.choice(descriptions),
            'start_date': start_date,
            'cost': round(random.uniform(50, 550), 2),
            'technician': random.choice(technicians),
            'status': random.choice(statuses),
        }
        
        
        if end_date:
            log_entry['end_date'] = end_date
            
        logs.append(log_entry)
    
    return logs

def save_to_csv_with_default_status(logs, filename='maintenance_logs.csv'):
    with open(filename, 'w', newline='', encoding='utf-8') as f:
        fieldnames = ['item_type', 'item_id', 'maintenance_type', 'description', 
                      'start_date', 'end_date', 'cost', 'technician', 'status']
        writer = csv.DictWriter(f, fieldnames=fieldnames, delimiter='\t')
        writer.writeheader()
        valid_statuses = {'scheduled', 'in progress', 'completed', 'cancelled'}
        for log in logs:
            status = log.get('status', 'scheduled').strip()
            if status not in valid_statuses:
                status = 'scheduled'
            row = {
                'item_type': log['item_type'],
                'item_id': log['item_id'],
                'maintenance_type': log['maintenance_type'],
                'description': log['description'],
                'start_date': log['start_date'],
                'end_date': log.get('end_date', ''),
                'cost': f"{log['cost']:.2f}",
                'technician': log['technician'],
                'status': status
            }
            writer.writerow(row)

if __name__ == '__main__':
    rooms = load_ids_with_generated_ids('rooms.csv')  
    cars = load_ids_with_generated_ids('cars.csv')   

    logs = generate_maintenance_logs(rooms, cars, limit=1000)
    save_to_csv_with_default_status(logs)

    print(f"Generated {len(logs)} maintenance logs to 'maintenance_logs.csv'.")

