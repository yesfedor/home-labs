# Testing Environment Setup

This environment is designed for automated testing, CI/CD pipelines, and staging deployments before production.

## Purpose

The testing environment mirrors production configurations but may use different resource limits, mock services, or ephemeral data storage.

## Setup

1.  **Clone the Repository:**
    ```bash
    git clone <repo_url> home-labs
    cd home-labs
    ```

2.  **Configure Environment:**
    Copy `configs/local.env` to `configs/test.env` (or create a specific test config).
    ```bash
    cp configs/local.env configs/test.env
    ```
    *Modify variables as needed for the test environment (e.g., different database names).*

3.  **Start the Stack:**
    ```bash
    make up ENV_TYPE=test
    ```
    This uses `ci/docker-compose.test.yml` which adds specific testing tools or configurations.

## Running Tests

(Add specific testing commands here, e.g., running a test suite against the API)

```bash
# Example: Run integration tests
docker-compose -f ci/docker-compose.test.yml run --rm test-runner npm test
```

## Cleanup

To reset the test environment completely:

```bash
make clean-volumes ENV_TYPE=test
```
