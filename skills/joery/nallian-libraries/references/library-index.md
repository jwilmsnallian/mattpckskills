# Nallian Extensions Library Index

Quick reference for all libraries in `Nallian.Extensions`.

## Core & Common

| Library | Description |
|---------|-------------|
| **Nallian.Common** | Foundation: Result pattern (FluentResults), common exceptions, extension methods |
| **Nallian.Api.Common** | API framework: base controllers, error handling, Swagger setup |
| **Nallian.Api.Sdk** | SDK base classes for building typed HTTP clients for Nallian APIs |
| **Nallian.Api.Sdk.Abstractions** | Abstractions for the API SDK |
| **Nallian.Extensions.Configuration** | Configuration binding extensions and validation |
| **Nallian.Cli** | CLI tools for service bus and storage operations |

## Data Access

| Library | Description |
|---------|-------------|
| **Nallian.Data** | Entity Framework Core integration with resilience patterns |
| **Nallian.Data.Abstractions** | Interfaces for data access (IReadOnlyContext, IReadWriteContext) |
| **Nallian.Data.Audit** | Automatic audit trail for EF Core entity changes |
| **Nallian.Data.Audit.Api** | API endpoints to expose audit data |
| **Nallian.Data.Dapper** | Dapper integration for raw SQL queries |
| **Nallian.Data.Mongo** | MongoDB repository pattern implementation |
| **Nallian.Data.Mongo.Abstractions** | MongoDB abstractions |
| **Nallian.Data.UnitOfWork** | Unit of Work pattern over EF Core |
| **Nallian.Data.UnitOfWork.Abstractions** | UoW interfaces |

## Azure Services

| Library | Description |
|---------|-------------|
| **Nallian.AzureBlobStorage** | Azure Blob Storage operations (upload, download, list, etc.) |
| **Nallian.AzureBlobStorage.Abstractions** | Blob storage interfaces |
| **Nallian.AzureBlobStorage.Mutex** | Distributed locking and leader election via blob leases |
| **Nallian.AzureQueues** | Azure Queue Storage messaging |
| **Nallian.AzureQueues.Outbox.Abstractions** | Outbox pattern abstractions for queue messages |
| **Nallian.AzureQueues.Outbox.EFCore.SqlServer** | Outbox pattern for queues with EF Core + SQL Server |
| **Nallian.AzureStorage.Abstractions** | Common Azure storage abstractions |
| **Nallian.BlobStorage.Abstractions** | Generic blob storage abstractions |
| **Nallian.TableStorage** | Azure Table Storage operations |
| **Nallian.TableStorage.Abstractions** | Table storage interfaces |

## Messaging & Service Bus

| Library | Description |
|---------|-------------|
| **Nallian.ServiceBus** | Azure Service Bus messaging (publish/subscribe, topics, queues) |
| **Nallian.ServiceBus.Abstractions** | Service Bus interfaces (IMessagePublisher, IMessageHandler) |
| **Nallian.ServiceBus.Outbox.Abstractions** | Outbox pattern abstractions for Service Bus |
| **Nallian.ServiceBus.Outbox.EFCore** | Outbox pattern for Service Bus with EF Core |
| **Nallian.ServiceBus.Outbox.EFCore.SqlServer** | SQL Server-specific outbox for Service Bus |

## Security & Authorization

| Library | Description |
|---------|-------------|
| **Nallian.Security** | Principal-based authorization, features, multi-tenancy |
| **Nallian.Security.Abstractions** | Security interfaces (IPrincipal, IFeature, etc.) |
| **Nallian.Security.Authentication** | Authentication middleware and token validation |
| **Nallian.Security.Authorization.Core** | Authorization framework and policy evaluation |
| **Nallian.Security.Helper** | Security utility helpers |
| **Nallian.Security.Helper.Abstractions** | Security helper interfaces |

## Observability & Monitoring

| Library | Description |
|---------|-------------|
| **Nallian.Logging** | Serilog integration, Application Insights, Sentry sinks |
| **Nallian.Monitoring.Sdk** | Monitoring SDK and telemetry |
| **Nallian.Monitoring.AspNetCore** | ASP.NET Core monitoring middleware |
| **Nallian.Monitoring.WorkerService** | Worker service monitoring |
| **Nallian.Monitoring.Abstractions** | Monitoring abstractions |
| **Nallian.HealthChecks** | Kubernetes-ready health checks (liveness, readiness) |
| **Nallian.HealthChecks.Abstractions** | Health check interfaces |

## Caching

| Library | Description |
|---------|-------------|
| **Nallian.Cache** | In-memory and distributed Redis caching |
| **Nallian.Cache.Abstractions** | Caching interfaces |

## Business Features

| Library | Description |
|---------|-------------|
| **Nallian.AlertManager** | Alert management system |
| **Nallian.AlertManager.Abstractions** | Alert manager interfaces |
| **Nallian.AlertManager.MongoDb** | MongoDB-backed alert storage |
| **Nallian.Dashboards** | Dashboard framework with Luzmo integration |
| **Nallian.DataProtection** | Data protection and encryption |
| **Nallian.Idempotency** | Idempotent message processing |
| **Nallian.Idempotency.SqlServer** | SQL Server idempotency store |
| **Nallian.KeyVault** | Azure Key Vault integration |
| **Nallian.Quartz** | Background job scheduling with Quartz.NET |
| **Nallian.Smtp** | Email sending via SMTP |
| **Nallian.StoredGridView** | Stored grid view management |
| **Nallian.StoredGridView.Abstractions** | Grid view interfaces |
| **Nallian.StoredGridView.BlobStorage** | Blob-backed grid view storage |
| **Nallian.Extensions.Availability** | Service availability checking |
| **Nallian.Extensions.Availability.Playwright** | Playwright-based availability checks |

## Source Locations

When looking up a library in the local clone (`~/nalcode/Nallian.Extensions/`):

- **Source code**: `src/<LibraryName>/`
- **Documentation**: `docs/packages/<LibraryName>/`
- **Tests**: `tests/<LibraryName>.Tests/` (naming varies)
- **Samples**: `samples/` (various sample projects demonstrating usage)
