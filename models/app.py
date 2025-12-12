# app.py

from flask import Flask, request, jsonify
import numpy as np
import pandas as pd
from recommender import recommend_recipes, load_embeddings  # Assuming you have a function to load embeddings

app = Flask(__name__)

# Load embeddings when the app starts
embedding_file = 'precomputed_embeddings.npy'

def load_embeddings(embedding_file):
    """Load precomputed embeddings from file."""
    try:
        embeddings = np.load(embedding_file, allow_pickle=True)
        return embeddings
    except Exception as e:
        print(f"Error loading embeddings: {e}")
        return None

# Load embeddings into a variable
embeddings = load_embeddings(embedding_file)

@app.route('/')
def home():
    return "Welcome to the Flask server!"

@app.route('/recommend', methods=['POST'])  # Ensure it only accepts POST requests
def recommend():
    try:
        data = request.get_json()  # Get the data sent to the server
        if not data:
            return jsonify({"error": "No data provided"}), 400  # Return an error if no data is sent
        
        # Get user preferences
        user_ingredients = data.get('ingredients')
        if not user_ingredients:
            return jsonify({"error": "Ingredients are required"}), 400
        
        diet = data.get('diet')
        prep_time = data.get('prep_time')
        course_category = data.get('course_category')

        # Use the preloaded embeddings to get recommendations
        if embeddings is None:
            return jsonify({"error": "Embeddings are not loaded properly"}), 500

        recommendations = recommend_recipes(user_ingredients, diet, prep_time, course_category, embeddings)

        # Check if recommendations are empty or invalid
        if not recommendations:
            return jsonify({"error": "No recommendations found"}), 404
        
        # Return the recommendations as a JSON response
        return jsonify({"recommendations": recommendations})
    
    except Exception as e:
        return jsonify({"error": str(e)}), 500  # Handle any unexpected errors

if __name__ == "__main__":
    app.run(debug=True)
