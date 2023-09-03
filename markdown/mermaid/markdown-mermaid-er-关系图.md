# markdown mermaid er 关系图

```mermaid
erDiagram
  CAR ||--o{ NAMED-DRIVER: allows
  CAR {
    string registrationNumber PK
    string make
    string model
    string[] parts
  }
  PERSON ||--o{ NAMED-DRIVER: is
  PERSON {
    string driversLicense PK "The license #"
    string(99) firstName "Only 99 characters are allowed"
    string lastName
    string phone UK
    int age
  }
  NAMED-DRIVER {
    string carRegistrationNumber PK, FK
    string driverLicence PK, FK
  }
  MANUFACTURER ||--o{ CAR: makes
```

关系符号

- `||`：一个
- `|o`, `o|`：零或一个
- `}o`, `o{`: 零或多个
- `}|`, `|{`: 一个或多个

## 参考链接

- [mermaid Entity Relationship Diagrams](https://mermaid.js.org/syntax/entityRelationshipDiagram.html)
