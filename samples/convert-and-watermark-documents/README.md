# Convert and Watermark Documents

Link: https://aws.amazon.com/blogs/architecture/convert-and-watermark-documents-automatically-with-amazon-s3-object-lambda/

```mermaid
block-beta
    columns 9
    space:6 db[("Document Db")] space:2

    space:9
    
    ext(("Internet")) space
    gw["Api Gateway"] space
    convert space 
    queue>"Processing Queue"] space
    watermark 
    
    space:9 
    
    space:2 auth["Cognito"] space
    result1[("Convert Results")] space:3
    result2[("Watermark Results")]

    ext --> gw
    gw --> auth
    gw --> convert
    convert --> queue
    queue --> watermark
    convert --> result1
    watermark --> result1
    watermark --> result2
    convert --> db
    watermark --> db
```
