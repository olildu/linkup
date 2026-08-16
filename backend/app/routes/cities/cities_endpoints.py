from typing import List
from fastapi import APIRouter

from app.utilities.cities_utilites.cities_utilities import search_cities

location_router = APIRouter(prefix="/locations")

@location_router.get("/india/search/{query}", response_model=List[str])
async def search_cities_func(query: str):
    return search_cities(query = query)