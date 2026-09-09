import cv2
import numpy as np
import warnings
from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from insightface.app import FaceAnalysis

# Silence the annoying InsightFace FutureWarnings
warnings.filterwarnings("ignore", category=FutureWarning)

app = FastAPI(title="Biometric Face Embedding API")

# Allow cross-origin requests
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

print("Loading AI Models... Please wait.")
# Buffalo_L is a highly accurate face detection & recognition pack
try:
    face_app = FaceAnalysis(name='buffalo_l', providers=['CPUExecutionProvider'])
    face_app.prepare(ctx_id=0, det_size=(640, 640))
    print("AI Models Loaded Successfully!")
except Exception as e:
    print(f"Error loading models: {e}")

def get_embedding_from_image(file_bytes):
    # Convert image bytes to numpy array
    nparr = np.frombuffer(file_bytes, np.uint8)
    # Decode to OpenCV BGR format
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    
    if img is None:
        return None
    
    # Detect faces
    faces = face_app.get(img)
    if not faces:
        return None
    
    # Sort faces by size (bounding box area) in descending order to get the largest face
    faces = sorted(faces, key=lambda x: (x.bbox[2]-x.bbox[0])*(x.bbox[3]-x.bbox[1]), reverse=True)
    
    # Return 512-d normalized face embedding
    return faces[0].normed_embedding.tolist()

@app.post("/extract-embedding")
async def extract_face_embedding(file: UploadFile = File(...)):
    bytes_data = await file.read()
    try:
        embedding = get_embedding_from_image(bytes_data)
    except Exception as e:
        print(f"Exception during extraction: {e}")
        raise HTTPException(status_code=500, detail=f"AI model inference failed: {str(e)}")
    
    if embedding is None:
        raise HTTPException(status_code=400, detail="No face detected in image")
        
    return {"status": "success", "embedding": embedding}

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
