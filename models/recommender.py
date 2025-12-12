
import pandas as pd
import numpy as np
from sentence_transformers import SentenceTransformer, util
import os
import re
from difflib import get_close_matches


file_path = 'Recipe_Rover_2.xlsx'
data = pd.read_excel(file_path)

model = SentenceTransformer('all-MiniLM-L6-v2')


synonym_map = {
    "vegetable oil": "sunflower oil",
    "all-purpose flour": "wheat flour",
    # Add more synonym mappings here
}

def get_closest_match(ingredient, synonyms):
    """Match ingredient to the closest synonym."""
    matches = get_close_matches(ingredient, synonyms.keys(), n=1, cutoff=0.8)
    return synonyms[matches[0]] if matches else ingredient


def normalize_ingredient(ingredient):
    """Normalize and map synonyms for ingredients."""
    ingredient = ingredient.lower().strip()
    ingredient = re.sub(r'[^a-zA-Z\s]', '', ingredient)  # Remove special characters
    return get_closest_match(ingredient, synonym_map)  # Find the closest match


data['Normalized_Ingredients'] = data['Short_Ingredients'].apply(
    lambda x: ', '.join([normalize_ingredient(ing) for ing in x.split(',')])
)

embedding_file = 'precomputed_embeddings.npy'

def load_embeddings(embedding_file='precomputed_embeddings.npy'):
    """Load precomputed embeddings from a file."""
    if os.path.exists(embedding_file):
        print("Loading precomputed embeddings...")
        embeddings = np.load(embedding_file, allow_pickle=True)
        return embeddings
    else:
        print("Embedding file not found. Please generate embeddings first.")
        return None

if not os.path.exists(embedding_file):
    print("Generating embeddings...")
    data['Ingredients_Embedding'] = data['Normalized_Ingredients'].apply(
        lambda ingredients: model.encode(ingredients, convert_to_tensor=False)
    )
    np.save(embedding_file, data['Ingredients_Embedding'].tolist())
else:
    print("Loading precomputed embeddings...")
    precomputed_embeddings = load_embeddings(embedding_file)
    data['Ingredients_Embedding'] = list(precomputed_embeddings)

print("Embeddings ready!")


def recommend_recipes(user_ingredients, diet, prep_time, course_category, embeddings, threshold=80):

    user_ingredients_list = [normalize_ingredient(ing.strip()) for ing in user_ingredients.split(',')]
    user_ingredients_normalized = ', '.join(user_ingredients_list)
    user_embedding = model.encode(user_ingredients_normalized, convert_to_tensor=False)  # Use CPU-only embedding

    recommendations = []
    for _, row in data.iterrows():

        if row['Diet'] != diet:
            continue
        if row['TotalTimeInMins'] > prep_time:
            continue
        if row['Course_Category'] != course_category:
            continue


        similarity_score_tensor = util.cos_sim(user_embedding, row['Ingredients_Embedding'])
        

        similarity_score_value = similarity_score_tensor.item()
        

        similarity_score_percentage = similarity_score_value * 100  # Convert to percentage

        recipe_ingredients_list = row['Normalized_Ingredients'].split(', ')
        matched_ingredients = set(user_ingredients_list).intersection(set(recipe_ingredients_list))
        missing_ingredients = set(recipe_ingredients_list) - matched_ingredients


        total_recipe_ingredients = len(recipe_ingredients_list)
        matching_percentage = int((len(matched_ingredients) / total_recipe_ingredients) * 100)  # Convert to integer

        if matching_percentage >= threshold:
            recommendations.append({
                "Recipe": row['Recipe'],
                "Servings": row['Servings'],
                "Full Ingredients": row['Long_Ingredients'],
                "Instructions": row['Instructions'],
                "Ingredients": row['Short_Ingredients'],
                "Matching Percentage": matching_percentage,
                "Missing Ingredients": ", ".join(missing_ingredients) if missing_ingredients else "No missing ingredient",
                "Image URL": row['Image URL'],
                "Diet": row['Diet'],
                "TotalTimeInMins": row['TotalTimeInMins'],
                "Course_Category": row['Course_Category'],
                "Cuisine": row['Cuisine'],
                "URL": row['URL']
            })


    recommendations = sorted(recommendations, key=lambda x: x['Matching Percentage'], reverse=True)

    return recommendations

