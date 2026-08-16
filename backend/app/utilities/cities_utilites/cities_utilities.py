import json

def search_cities(query: str):
    query_lower = query.lower()
    with open('app/constants/all_cities.json', 'r', encoding='utf-8') as file:
        cities = json.load(file)

    results = [
        f"{city}, {info['state']}"
        for city, info in cities.items()
        if query_lower in city.lower() or query_lower in info['state'].lower()
    ]
    
    return results[:20]
