# Insurance PAS QA Automation - Quick Reference

## 🏃 Quick Start (30 seconds)

```bash
# 1. Install dependencies
npm run setup

# 2. Verify API is running on http://localhost:8080

# 3. Run tests
npm test

# 4. Open report
open reports/insurance-qa-report.html
```

---

## 📋 Test Scenarios at a Glance

### 1️⃣ Happy Path (9 tests)
Complete quote lifecycle: Create → Submit → Approve → Issue

```
Agent → Client → Quote (DRAFT) → Insured → Cover → Attributes 
→ Submit (SUBMITTED) → Approve (APPROVED) → Issue (ISSUED)
```

**Files Tested**: All happy path scenarios in one continuous flow

---

### 2️⃣ Validation Tests (5 tests)
Missing fields and invalid enums

```
❌ Missing: name, email, agentId
❌ Invalid: gender enum, cover code
```

**Expected**: 400 Bad Request with error messages

---

### 3️⃣ Business Rules (2 tests)
Duplicate detection

```
❌ Duplicate attribute → 409 Conflict
❌ Duplicate insured → 409 Conflict
```

**Expected**: 409 Conflict errors

---

### 4️⃣ State Machine (3 tests)
Invalid state transitions

```
❌ DRAFT → APPROVED (skip SUBMITTED) → 400/409
✅ DRAFT → SUBMITTED → APPROVED → ISSUED
```

**Expected**: Transition validation errors

---

### 5️⃣ Data Integrity (4 tests)
Persistence and consistency checks

```
✅ Get quote → verify all entities present
✅ List quotes → find ISSUED quote
✅ Verify cover values persist
✅ Verify attribute values persist
```

**Expected**: All data matches input

---

### 6️⃣ Edge Cases (3 tests)
System behavior and error handling

```
❌ Non-existent ID → 404 Not Found
❌ Invalid date format → 400 Bad Request
❌ Negative premium → 400 Bad Request
```

**Expected**: Appropriate error codes and messages

---

## 🎯 Total: 26 Test Cases

| Category | Tests | Pass Criteria |
|----------|-------|---------------|
| Happy Path | 9 | All transitions succeed |
| Validation | 5 | 400 errors returned |
| Business Rules | 2 | 409 conflict errors |
| State Machine | 3 | Invalid transitions blocked |
| Data Integrity | 4 | Data persists correctly |
| Edge Cases | 3 | Appropriate error codes |
| **TOTAL** | **26** | **All pass** |

---

## 🛠️ Common Commands

```bash
# Run all tests with full output
npm test

# Run tests with enhanced HTML report
npm run test:verbose

# Quick test (CLI output only, no report)
npm run test:quick

# CI/CD mode (with exports)
npm run test:ci

# Clean and rebuild reports
npm run clean-reports

# Install Newman globally
npm run setup
```

---

## 📊 Report Files

After running tests:

```
reports/
├── insurance-qa-report.html          # 📈 Open in browser
└── insurance-qa-report.json          # 📝 For CI/CD parsing
```

**HTML Report includes:**
- ✅ All test results
- ✅ Pass/fail status
- ✅ Response times
- ✅ Assertion details
- ✅ Request/response bodies

---

## 🔧 Configuration Quick Reference

**Base URL**: `collections/insurance-env.json`
```json
{
  "key": "baseUrl",
  "value": "http://localhost:8080"
}
```

**Test Data**: `data/test-data.csv`
- 10 client profiles
- Ready for data-driven testing
- Edit to add more scenarios

**Collection**: `collections/insurance-enterprise.json`
- All 26 test cases
- Pre-request and test scripts
- Assertions included

---

## 💡 Key Features

✅ **Fail-Fast**: Stops on first failure to save time  
✅ **Data-Driven**: CSV test data for multiple scenarios  
✅ **Parameterized**: Environment variables for easy config  
✅ **CI/CD Ready**: GitHub Actions workflow included  
✅ **Comprehensive**: Coverage of happy path, validation, edge cases  
✅ **Assertions**: Status codes, structure, data integrity  
✅ **Reports**: HTML + JSON for analysis and dashboards  

---

## 🚨 Troubleshooting

| Issue | Solution |
|-------|----------|
| `newman: command not found` | `npm run setup` |
| Tests timeout | Increase timeout: `--timeout 120000` |
| Connection refused | Check API: `curl http://localhost:8080/health` |
| Report not created | `npm install -g newman-reporter-html` |
| 404 Not Found | Verify `baseUrl` in environment file |

---

## 📝 Assertion Summary

Each test includes assertions for:

1. **Status Code**
   ```javascript
   pm.test("Status code is 201", function () {
       pm.response.to.have.status(201);
   });
   ```

2. **Response Structure**
   ```javascript
   pm.test("Response has required fields", function () {
       var jsonData = pm.response.json();
       pm.expect(jsonData).to.have.all.keys('id', 'name', ...);
   });
   ```

3. **Data Validation**
   ```javascript
   pm.test("Data is correct", function () {
       var jsonData = pm.response.json();
       pm.expect(jsonData.status).to.equal('SUBMITTED');
   });
   ```

4. **Data Persistence**
   ```javascript
   pm.test("All entities persisted", function () {
       var jsonData = pm.response.json();
       pm.expect(jsonData.insuredList.length).to.be.greaterThan(0);
   });
   ```

---

## 🔄 CI/CD Integration

**GitHub Actions** (`.github/workflows/api-tests.yml`):

- Runs on: Push, PR, and daily schedule
- Node versions: 18.x, 20.x
- Reports: Uploaded as artifacts
- PR Comments: Automatic test result summary
- Fail condition: Any test failure

**Usage**: Just push to main/develop branch - tests run automatically!

---

## 📞 API Endpoints Reference

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/v1/agents` | POST | Create agent |
| `/api/v1/clients` | POST | Create client |
| `/api/v1/quotes` | POST | Create quote |
| `/api/v1/quotes/{id}` | GET | Get quote |
| `/api/v1/quotes` | GET | List quotes |
| `/api/v1/quotes/{id}/insured` | POST | Add insured |
| `/api/v1/quotes/{id}/covers` | POST | Add cover |
| `/api/v1/quotes/{id}/attributes` | POST | Add attribute |
| `/api/v1/quotes/{id}/submit` | PUT | Submit quote |
| `/api/v1/quotes/{id}/approve` | PUT | Approve quote |
| `/api/v1/quotes/{id}/issue` | PUT | Issue quote |

---

## 📚 Valid Enums

**Quote Status**: `DRAFT`, `SUBMITTED`, `APPROVED`, `ISSUED`

**Gender**: `MALE`, `FEMALE`

**Relationship**: `SELF`, `SPOUSE`, `CHILD`, `PARENT`

**Cover Code**: `LC` (Life Coverage)

**Data Type**: `STRING`, `NUMERIC`, `BOOLEAN`, `DATE`

---

**Version**: 1.0 | **Created**: April 2026 | **Status**: Ready for Use ✅
