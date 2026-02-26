# Module 1: Docker & PostgreSQL Data Ingestion

## 🧠 Why are we doing this?
In this module, we use **Docker** to containerize our PostgreSQL database, pgAdmin, and our Python ingestion script. 
* **Why Docker?** It ensures our environment is completely reproducible and isolated. We don't have to install PostgreSQL directly on our host machine, preventing dependency conflicts.
* **Why Docker Compose?** It allows us to define and run multi-container applications. With a single file (`docker-compose.yaml`), we can spin up both our database and pgAdmin UI on a shared local network.

---

## 🚀 The Workflow: What to run and How

### 1. Start the Database and pgAdmin
We define our `pgdatabase` and `pgadmin` services inside a `docker-compose.yaml` file. 
To start them, navigate to the folder containing the compose file and run:

```bash
docker-compose up -d
```

* **What it does:** Downloads the necessary images (if you don't have them) and starts the containers.
* **Why `-d`?** It runs the containers in detached mode (in the background), so you get your terminal prompt back.

### 2. Verify Services
* Open your browser and go to `localhost:8080` to access pgAdmin.
* Log in using the credentials defined in your compose file.
* Add a new server connection inside pgAdmin using the database container name (e.g., `pgdatabase`), port (`5432`), database name, user, and password.

### 3. Build the Ingestion Script Image
We use a `Dockerfile` to package our `ingest_data.py` script along with its dependencies (`pandas`, `sqlalchemy`, `psycopg2`).

```bash
docker build -t taxi_ingest:v001 .
```

* **What it does:** Builds a Docker image named `taxi_ingest` with the tag `v001` based on the instructions in your `Dockerfile`.

### 4. Run the Data Ingestion
Now we run our ingestion container. Because our script needs to talk to the PostgreSQL container, we must attach it to the network created by Docker Compose.

```bash
docker run -it \
  --network=pipeline_default \
  taxi_ingest:v001 \
    --user=root \
    --password=root \
    --host=pgdatabase \
    --port=5432 \
    --db=ny_taxi \
    --table_name=yellow_taxi_trips \
    --url="<URL_TO_THE_CSV_FILE>"
```

* **What it does:** Starts the container and executes the Python script.
* **Why `--network=pipeline_default`?** This is crucial. It puts your python script on the same virtual network as your database, allowing the script to resolve `--host=pgdatabase` instead of using `localhost`.
* **The arguments:** These are passed directly to `argparse` in `ingest_data.py` to configure the SQLAlchemy database engine and fetch the data.

### 5. Teardown
When you are done, stop and remove the containers:

```bash
docker-compose down
```

* **What it does:** Stops the running containers and gracefully removes them along with the default network, freeing up local resources.