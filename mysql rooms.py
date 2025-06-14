import random
import csv

user_ids = list(range(1, 1001))

streets = [
    'Main St', 'Oak Ave', 'Pine Rd', 'Maple Blvd', 'Cedar Ln',
    'Elm St', 'Spruce Dr', 'Walnut Ct', 'Chestnut Way', 'Birch Pl',
    'Willow St', 'Ash Ave', 'Poplar Rd', 'Sycamore Blvd', 'Magnolia Ln',
    'Hickory St', 'Beech Dr', 'Redwood Ct', 'Palm Way', 'Fir Pl'
]

def generate_street():
    number = random.randint(1, 9999)
    street_name = random.choice(streets)
    return f"{number} {street_name}"

def generate_rooms(num_rooms, user_ids):
    rooms = []
    for _ in range(num_rooms):
        street = generate_street()
        owner_id = random.choice(user_ids)
        rooms.append((street, owner_id))
    return rooms

def save_rooms_to_csv(rooms, filename="rooms.csv"):
    with open(filename, 'w', newline='', encoding='utf-8') as csvfile:
        csv_writer = csv.writer(csvfile)
        csv_writer.writerow(['street', 'owner_id'])  
        csv_writer.writerows(rooms)
num_rooms = 1000

rooms_data = generate_rooms(num_rooms, user_ids)

save_rooms_to_csv(rooms_data)

print(f"CSV файл 'rooms.csv' успішно згенеровано з {num_rooms} записами.")
