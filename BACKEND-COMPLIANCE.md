# Insurance PAS - Backend Compliance Migration Guide

## Overview

The Postman collection has been **completely updated** to strictly match the Spring Boot Insurance PAS backend specifications. All requests now comply with the exact DTO structures and API endpoints defined.

---

## ✅ Changes Made

### 1. **Base URL Updates**

**BEFORE:**
```
{{baseUrl}}/api/v1/agents
{{baseUrl}}/api/v1/clients
{{baseUrl}}/api/v1/quotes
```

**AFTER:**
```
{{baseUrl}}/agents
{{baseUrl}}/clients
{{baseUrl}}/quotes
```

✅ Removed `/api/v1` prefix from all endpoints  
✅ Using clean root-level paths matching backend routers

---

### 2. **Agent DTO Compliance**

**BEFORE:**
```json
{
  "name": "Premium Agents Inc",
  "email": "info@premiumagents.com"
}
```

**AFTER:**
```json
{
  "name": "Premium Agents Inc",
  "email": "info@premiumagents.com",
  "phoneNumber": "+1-555-0100",
  "role": "AGENT"
}
```

✅ Added mandatory `phoneNumber` field  
✅ Added mandatory `role` enum field  
✅ All required fields now present

---

### 3. **Client DTO Compliance**

**BEFORE:**
```json
{
  "name": "John Doe",
  "email": "john.doe@example.com",
  "phone": "+1-555-0123",
  "address": "123 Main St, New York, NY 10001"
}
```

**AFTER:**
```json
{
  "name": "John Doe",
  "clientType": "INDIVIDUAL",
  "idType": "AADHAAR",
  "email": "john.doe@example.com",
  "phoneNumber": "+1-555-0123",
  "agentId": 1,
  "addresses": [
    {
      "line1": "123 Main Street",
      "city": "New York",
      "state": "NY",
      "country": "USA",
      "postalCode": "10001",
      "addressType": "PERMANENT",
      "isMainAddress": true
    }
  ]
}
```

**Key Changes:**
- ✅ Added `clientType: "INDIVIDUAL"` (required enum)
- ✅ Added `idType: "AADHAAR"` (required enum)
- ✅ Renamed `phone` → `phoneNumber`
- ✅ Added `agentId` (numeric reference)
- ✅ Replaced single address string with `addresses` array
- ✅ Address object now has proper structure with `line1`, `city`, `state`, `country`, `postalCode`, `addressType`, `isMainAddress`

---

### 4. **Quote DTO Compliance**

**BEFORE:**
```json
{
  "agentId": "{{agentId}}",
  "clientId": "{{clientId}}",
  "quoteReference": "QT-2026-001"
}
```

**AFTER:**
```json
{
  "clientId": 1,
  "agentId": 1
}
```

**Key Changes:**
- ✅ Removed `quoteReference` field (not in DTO)
- ✅ Using numeric IDs instead of strings
- ✅ Simplified to only required fields

---

### 5. **Insured DTO Compliance**

**BEFORE:**
```json
{
  "name": "Jane Smith",
  "dateOfBirth": "1985-06-15",
  "gender": "FEMALE",
  "relationship": "SPOUSE"
}
```

**AFTER:**
```json
{
  "clientId": 1,
  "role": "PRIMARY",
  "isPrimary": true
}
```

**Key Changes:**
- ✅ Removed `name`, `dateOfBirth`, `gender`, `relationship` (not in DTO)
- ✅ Added mandatory `clientId` (numeric)
- ✅ Added mandatory `role` enum (`PRIMARY`)
- ✅ Added mandatory `isPrimary` boolean

---

### 6. **Cover DTO Compliance**

**BEFORE:**
```json
{
  "coverCode": "LC",
  "coverName": "Life Coverage",
  "sumInsured": 500000,
  "premium": 5000
}
```

**AFTER:**
```json
{
  "insuredId": 1,
  "coverCode": "LC",
  "coverType": "BASE",
  "sumAssured": 500000,
  "termYears": 20,
  "commencementDate": "2026-04-20"
}
```

**Key Changes:**
- ✅ Added mandatory `insuredId` (numeric)
- ✅ Renamed `sumInsured` → `sumAssured`
- ✅ Removed `coverName` (not in DTO)
- ✅ Added mandatory `coverType: "BASE"` (enum)
- ✅ Removed `premium` field
- ✅ Added mandatory `termYears` (numeric)
- ✅ Added mandatory `commencementDate` (date string YYYY-MM-DD)

---

### 7. **Attribute DTO Compliance**

**BEFORE:**
```json
{
  "attributeName": "premium_amount",
  "attributeValue": "50000",
  "dataType": "NUMERIC"
}
```

**AFTER:**
```json
{
  "attributeKey": "premium_rate",
  "valueType": "NUMBER",
  "numberValue": 125.50
}
```

**Endpoint Changes:**
- ✅ Changed from: `POST /quotes/{id}/attributes`
- ✅ Changed to: `POST /covers/{id}/attributes`

**Key Changes:**
- ✅ Renamed `attributeName` → `attributeKey`
- ✅ Renamed `dataType` → `valueType` with enum values: `STRING | NUMBER`
- ✅ Renamed `attributeValue` → `stringValue` or `numberValue` (conditional)
- ✅ Moved from Quote to Cover endpoint

---

### 8. **Status Update Changes**

**BEFORE:**
```
PUT /api/v1/quotes/{{quoteId}}/submit
PUT /api/v1/quotes/{{quoteId}}/approve  
PUT /api/v1/quotes/{{quoteId}}/issue
```

**AFTER:**
```
PATCH /quotes/{{quoteId}}/status
PATCH /quotes/{{quoteId}}/status
PATCH /quotes/{{quoteId}}/status
```

**Request Body Updated:**

**BEFORE:**
```json
{}  // for submit
{"approverComments": "..."} // for approve
{"issueComments": "..."} // for issue
```

**AFTER:**
```json
{"status": "SUBMITTED"}
{"status": "APPROVED"}
{"status": "ISSUED"}
```

✅ Unified all status updates to single PATCH endpoint  
✅ All use consistent status enum in request body  
✅ Valid values: `SUBMITTED | APPROVED | ISSUED`

---

### 9. **Environment Variables Updated**

**Added Variables:**
```
agentPhoneNumber: +1-555-0100
agentRole: AGENT
clientType: INDIVIDUAL
idType: AADHAAR
addressType: PERMANENT
insuredRole: PRIMARY
coverCode: LC
coverType: BASE
sumAssured: 500000
termYears: 20
commencementDate: 2026-04-20
attributeKey: premium_rate
attributeValueType: NUMBER
attributeNumberValue: 125.50
```

**Removed Variables:**
- agentName
- clientName, clientEmail
- insuredName
- coverName
- attributeName, attributeValue

---

### 10. **Test Assertions Updated**

All assertions updated to validate:

✅ Correct field names (e.g., `sumAssured` not `sumInsured`)  
✅ Correct enums (e.g., `INDIVIDUAL`, `AADHAAR`, `LC`, `BASE`, etc.)  
✅ Required fields present in responses  
✅ Proper data types (numbers, strings, booleans, arrays)  

**Example:**
```javascript
// Before
pm.expect(jsonData.sumInsured).to.equal(500000);

// After
pm.expect(jsonData.sumAssured).to.equal(500000);
```

---

## 📋 Complete API Reference

### Agents
| Endpoint | Method | Body |
|----------|--------|------|
| `/agents` | POST | name, email, phoneNumber, role |

### Clients
| Endpoint | Method | Body |
|----------|--------|------|
| `/clients` | POST | name, clientType, idType, email, phoneNumber, agentId, addresses[] |

### Quotes
| Endpoint | Method | Body |
|----------|--------|------|
| `/quotes` | POST | clientId, agentId |
| `/quotes/{id}` | GET | - |
| `/quotes/{id}/status` | PATCH | status (SUBMITTED\|APPROVED\|ISSUED) |

### Insured
| Endpoint | Method | Body |
|----------|--------|------|
| `/quotes/{id}/insured` | POST | clientId, role, isPrimary |

### Covers
| Endpoint | Method | Body |
|----------|--------|------|
| `/quotes/{id}/covers` | POST | insuredId, coverCode, coverType, sumAssured, termYears, commencementDate |
| `/covers/{id}` | GET | - |

### Attributes
| Endpoint | Method | Body |
|----------|--------|------|
| `/covers/{id}/attributes` | POST | attributeKey, valueType, stringValue\|numberValue |

---

## ✅ Enum Reference

**Agent Role:** `AGENT`

**Client Type:** `INDIVIDUAL`

**ID Type:** `AADHAAR`

**Address Type:** `PERMANENT`

**Insured Role:** `PRIMARY`

**Cover Code:** `LC`

**Cover Type:** `BASE`

**Attribute Value Type:** `STRING`, `NUMBER`

**Quote Status:** `SUBMITTED`, `APPROVED`, `ISSUED`

---

## 🔍 Validation Examples

### Valid Create Agent Request
```json
{
  "name": "Premium Agents Inc",
  "email": "info@premiumagents.com",
  "phoneNumber": "+1-555-0100",
  "role": "AGENT"
}
```

### Valid Create Client Request
```json
{
  "name": "John Doe",
  "clientType": "INDIVIDUAL",
  "idType": "AADHAAR",
  "email": "john.doe@example.com",
  "phoneNumber": "+1-555-0123",
  "agentId": 1,
  "addresses": [
    {
      "line1": "123 Main Street",
      "city": "New York",
      "state": "NY",
      "country": "USA",
      "postalCode": "10001",
      "addressType": "PERMANENT",
      "isMainAddress": true
    }
  ]
}
```

### Valid Create Quote Request
```json
{
  "clientId": 1,
  "agentId": 1
}
```

### Valid Add Cover Request
```json
{
  "insuredId": 1,
  "coverCode": "LC",
  "coverType": "BASE",
  "sumAssured": 500000,
  "termYears": 20,
  "commencementDate": "2026-04-20"
}
```

### Valid Add Attribute Request
```json
{
  "attributeKey": "premium_rate",
  "valueType": "NUMBER",
  "numberValue": 125.50
}
```

### Valid Status Update Request
```json
{
  "status": "SUBMITTED"
}
```

---

## 🚀 Running Tests with Backend-Compliant Collection

```bash
# Run all tests
npm test

# Quick validation
npm run test:quick

# CI/CD mode
npm run test:ci
```

---

## ✨ Summary of Strict Compliance

✅ **No invented fields** - All fields from backend specs only  
✅ **Correct enums** - Using exact enum values  
✅ **Correct field names** - Matching backend DTOs exactly  
✅ **No /api/v1 prefix** - Using clean root paths  
✅ **Numeric IDs** - Not strings  
✅ **Proper HTTP methods** - PATCH for status, not PUT  
✅ **Valid dates** - YYYY-MM-DD format  
✅ **All mandatory fields** - No missing required properties  

---

**Collection Version:** 2.0 (Backend Compliant)  
**Migration Date:** April 20, 2026  
**Status:** ✅ Ready for Production Testing
