# S3 Client App — Cross-Platform Object Storage Manager

> A cross-platform Flutter application for managing files and buckets on **S3-compatible storage systems**, developed as part of my diploma thesis.  

## Overview

This project showcases a **complete S3-compatible client ecosystem**, composed of three main components:

1. **MinIO Server** – acts as the S3-compatible object storage backend (hosted locally, can be replaced by any other provider that supports S3 compatible APIs).  
2. **Spring Boot Backend App** – acts as a proxy layer, targeting S3-compatible providers (see my [Spring Boot S3 Backend Project](https://github.com/DaniloVrancic/s3-backend)).  
3. **Flutter Frontend App (this repo)** – the mobile and desktop client used to view, upload, download, and manage objects and buckets stored in the S3 backend.

<p style="align-items:center">
  <img 
    src="assets/docs/System-Components.drawio.png"
    style="min-width: 80%; width: 100%"
    alt="System Components" />
</p>

---
