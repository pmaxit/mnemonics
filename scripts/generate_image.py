import os
import sys
import argparse
from dotenv import load_dotenv

try:
    from google import genai
    from google.genai import types
except ImportError:
    print("Please install google-genai package: pip install google-genai")
    sys.exit(1)

def generate_image_for_word(word):
    # Load environment variables (expecting GEMINI_API_KEY)
    load_dotenv()
    
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        print("Error: GEMINI_API_KEY not found in .env or environment variables.")
        sys.exit(1)
        
    print(f"Generating image for word: '{word}' using Nano Banana (gemini-2.5) model...")
    
    # Initialize the client
    client = genai.Client(api_key=api_key)
    
    try:
        # Construct a prompt for a vocabulary word
        prompt = f"A beautiful, artistic illustration that clearly represents the vocabulary word '{word}'. The image should be memorable, vibrant, and help someone remember the meaning of the word without containing any text."
        
        # Use the nano banana model (gemini-2.5-flash-image)
        result = client.models.generate_images(
            model='gemini-2.5-flash-image',
            prompt=prompt,
            config=types.GenerateImagesConfig(
                number_of_images=1,
                aspect_ratio="1:1",
                output_mime_type="image/jpeg",
                person_generation="ALLOW_ADULT"
            )
        )
        
        if not result.generated_images:
            print("No image was generated.")
            return

        # Prepare output directory
        output_dir = "assets/generated_images"
        os.makedirs(output_dir, exist_ok=True)
        
        output_file = os.path.join(output_dir, f"{word.lower().replace(' ', '_')}.jpg")
        
        # Save the image
        for generated_image in result.generated_images:
            image = generated_image.image
            
            with open(output_file, 'wb') as f:
                f.write(image.image_bytes)
                
            print(f"Successfully saved image for '{word}' to: {output_file}")
            
    except Exception as e:
        print(f"Error generating image: {e}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate an image for a vocabulary word using the Nano Banana model")
    parser.add_argument("word", help="The vocabulary word to generate an image for")
    
    args = parser.parse_args()
    generate_image_for_word(args.word)
