# Backend Compliance - Quick Endpoint Reference

## 🔄 Migration Summary

| Entity | Before | After | Status |
|--------|--------|-------|--------|
| **Base URL** | /api/v1/* | /* | ✅ Fixed |
| **Agent Endpoint** | POST /api/v1/agents | POST /agents | ✅ Fixed |
| **Client Endpoint** | POST /api/v1/clients | POST /clients | ✅ Fixed |
| **Quote Endpoint** | POST /api/v1/quotes | POST /quotes | ✅ Fixed |
| **Status Update** | PUT /api/v1/quotes/{id}/submit | PATCH /quotes/{id}/status | ✅ Fixed |
| **Insured Endpoint** | POST /api/v1/quotes/{id}/insured | POST /quotes/{id}/insured | ✅ Fixed |
| **Cover Endpoint** | POST /api/v1/quotes/{id}/covers | POST /quotes/{id}/covers | ✅ Fixed |
| **Attribute Endpoint** | POST /api/v1/quotes/{id}/attributes | POST /covers/{id}/attributes | ✅ Fixed |

---

## 📦 DTO Field Changes

### Agent DTO
```diff
{
  "name": "...",
  "email": "...",
+ "phoneNumber": "...",
+ "role": "AGENT"
}
```

### Client DTO
```diff
{
  "name": "...",
+ "clientType": "INDIVIDUAL",
+ "idType": "AADHAAR",
  "email": "...",
- "phone": "..."
+ "phoneNumber": "...",
+ "agentId": 1,
- "address": "..."
+ "addresses": [{
+   "line1": "...",
+   "city": "...",
+   "state": "...",
+   "country": "...",
+   "postalCode": "...",
+   "addressType": "PERMANENT",
+   "isMainAddress": true
+ }]
}
```

### Quote DTO
```diff
{
  "clientId": 1,
  "agentId": 1
- "quoteReference": "..."
}
```

### Insured DTO
```diff
{
+ "clientId": 1,
+ "role": "PRIMARY",
+ "isPrimary": true
- "name": "...",
- "dateOfBirth": "...",
- "gender": "...",
- "relationship": "..."
}
```

### Cover DTO
```diff
{
+ "insuredId": 1,
  "coverCode": "LC",
+ "coverType": "BASE",
- "coverName": "...",
- "sumInsured": 500000,
- "premium": 5000
+ "sumAssured": 500000,
+ "termYears": 20,
+ "commencementDate": "2026-04-20"
}
```

### Attribute DTO
```diff
{
- "attributeName": "...",
- "attributeValue": "...",
- "dataType": "NUMERIC"
+ "attributeKey": "...",
+ "valueType": "NUMBER",
+ "numberValue": 125.50
}
```

### Status Update DTO
```diff
- PUT /quotes/{id}/submit {}
- PUT /quotes/{id}/approve {approverComments: "..."}
- PUT /quotes/{id}/issue {issueComments: "..."}

+ PATCH /quotes/{id}/status {"status": "SUBMITTED"}
+ PATCH /quotes/{id}/status {"status": "APPROVED"}
+ PATCH /quotes/{id}/status {"status": "ISSUED"}
```

---

## ✅ Enum Values (Strict)

```
agentRole: "AGENT"
clientType: "INDIVIDUAL"
idType: "AADHAAR"
addressType: "PERMANENT"
insuredRole: "PRIMARY"
coverCode: "LC"
coverType: "BASE"
attributeValueType: "STRING" | "NUMBER"
quoteStatus: "SUBMITTED" | "APPROVED" | "ISSUED"
```

---

## 🧪 Test Coverage Now Includes

✅ Happy Path (9 tests) - Full lifecycle with corrected DTOs  
✅ Validation Tests (3 tests) - Missing required fields  
✅ Invalid Enum Tests (4 tests) - Wrong enum values  
✅ Business Rules (3 tests) - Data constraints  
✅ GET Operations (2 tests) - Data retrieval  
✅ Error Scenarios (3 tests) - Edge cases & 404s  

**Total: 24 tests** (all backend-compliant)

---

## 🚀 Usage

```bash
# Run collection (backend-compliant)
newman run collections/insurance-enterprise.json \
  --environment collections/insurance-env.json

# With full output
npm test

# Quick test
npm run test:quick
```

---

## ✨ Key Points

1. **No /api/v1** - Direct root paths
2. **Numeric IDs** - No string IDs
3. **PATCH for status** - Not PUT
4. **Proper DTOs** - Exact field names and enums
5. **No invented fields** - Only spec-defined fields
6. **Correct data types** - Numbers, strings, booleans, arrays
7. **Date format** - YYYY-MM-DD strings
8. **Object nesting** - addresses array, not flat string

---

## 📝 Migration Date
April 20, 2026 - Collection fully migrated to backend specifications ✅
