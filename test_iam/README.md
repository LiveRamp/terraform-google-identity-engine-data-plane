### Command
```
./test_iam.sh \
<project-id> \
<tenant-svc> \
<input-bucket> \
<build-bucket> \
<output-bucket> \
<bq-dataset>
```
### Example
```
./test_iam.sh \
id-graph-gl-dev-tenant-data \
liveramp-engineering-9535cadb@id-graph-gl-dev-tenant-data.iam.gserviceaccount.com \
portrait-engine-global-dev-liveramp-engineering-us-input \
portrait-engine-global-dev-liveramp-engineering-us-build \
portrait-engine-global-dev-liveramp-engineering-us-output \
portrait_engine_liveramp_engineering_us
```