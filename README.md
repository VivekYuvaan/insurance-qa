# Insurance Policy Administration System (PAS) - QA Automation

Complete QA automation test suite for Insurance PAS Spring Boot application.

## 📋 Project Structure

```
insurance-qa/
├── collections/
│   ├── insurance-enterprise.json    # Main Postman collection with all test scenarios
│   └── insurance-env.json           # Environment variables configuration
├── data/
│   └── test-data.csv                # Sample test data with 10 client profiles
├── scripts/
│   └── run-tests.sh                 # Bash script to execute tests with Newman
├── reports/                          # Generated test reports (created on test run)
├── .github/workflows/
│   └── api-tests.yml                # GitHub Actions CI/CD pipeline
├── .gitignore                       # Git ignore rules
└── README.md                        # This file
```

## 🎯 Test Coverage

### 1. **Happy Path: Complete Quote Lifecycle** (9 tests)
- Create Agent
- Create Client
- Create Quote (DRAFT)
- Add Insured
- Add Cover
- Add Attributes
- Submit Quote (DRAFT → SUBMITTED)
- Approve Quote (SUBMITTED → APPROVED)
- Issue Quote (APPROVED → ISSUED)

**Assertions**: Status codes, response structure, lifecycle correctness, data persistence

### 2. **Validation Tests: Missing Fields** (3 tests)
- Create Client without name
- Create Client without email
- Create Quote without agentId

**Assertions**: 400 status codes, error messages contain field names

### 3. **Validation Tests: Invalid Enums** (2 tests)
- Add Insured with invalid gender enum
- Add Cover with invalid cover code

**Assertions**: 400 status codes, enum validation errors

### 4. **Business Rules: Duplicate Detection** (2 tests)
- Add duplicate attribute
- Add duplicate insured

**Assertions**: 409 Conflict status, duplicate error messages

### 5. **State Machine Tests: Invalid Transitions** (3 tests)
- Try to approve without submitting (DRAFT → APPROVED)
- Try invalid state transitions
- Verify state transition rules enforced

**Assertions**: 400/409 status codes, transition error messages

### 6. **Data Integrity Tests** (4 tests)
- Get quote and verify all entities persist
- List all quotes and verify ISSUED quote included
- Verify cover details persist with correct values
- Verify attribute values persist correctly

**Assertions**: Data matches input, relationships intact, timestamps in correct order

### 7. **Edge Cases: System Behavior** (3 tests)
- Get non-existent quote (404)
- Invalid date format validation
- Negative premium amount validation

**Assertions**: 404 status, validation error messages

**Total: 26 comprehensive test cases**

## 🚀 Quick Start

### Prerequisites

1. **Node.js** (v14+)
2. **Newman** (Postman CLI)
3. **Insurance PAS API** running on `http://localhost:8080`

### Installation

```bash
# Install Newman globally
npm install -g newman
npm install -g newman-reporter-html

# Clone/download this project
cd insurance-qa

# Make script executable
chmod +x scripts/run-tests.sh
```

### Running Tests

#### Option 1: Using Bash Script
```bash
./scripts/run-tests.sh
```

#### Option 2: Direct Newman Command
```bash
newman run collections/insurance-enterprise.json \
  --environment collections/insurance-env.json \
  --reporters cli,html,json \
  --reporter-html-export reports/insurance-qa-report.html \
  --reporter-json-export reports/insurance-qa-report.json \
  --bail \
  --verbose
```

#### Option 3: Using GitHub Actions
Push to main/develop branch or trigger manually - tests run automatically

### 📊 Test Reports

After running tests, reports are generated in the `reports/` directory:

- **insurance-qa-report.html** - Visual HTML report (open in browser)
- **insurance-qa-report.json** - Detailed JSON report (for CI/CD integration)

## 📝 Configuration

### Environment Variables (`collections/insurance-env.json`)

Edit the environment file to customize:

```json
{
  "key": "baseUrl",
  "value": "http://localhost:8080"
}
```

**Available Variables:**
- `baseUrl` - API base URL
- `agentId` - Agent identifier
- `clientId` - Client identifier
- `quoteId` - Quote identifier
- `insuredId` - Insured person identifier
- `coverId` - Cover identifier
- `attributeId` - Attribute identifier
- `coverCode` - Valid cover code (LC)

### Test Data (`data/test-data.csv`)

Sample data with 10 client profiles for data-driven testing:
- Client names and contact information
- Insured person details (DOB, gender, relationship)
- Cover information (code, amounts, premiums)
- Custom attributes

Use this for batch testing scenarios.

## 🔒 API Contract

### Base URL
```
http://localhost:8080/api/v1
```

### Endpoints Tested

| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | `/agents` | Create agent |
| POST | `/clients` | Create client |
| POST | `/quotes` | Create quote |
| POST | `/quotes/{id}/insured` | Add insured |
| POST | `/quotes/{id}/covers` | Add cover |
| POST | `/quotes/{id}/attributes` | Add attribute |
| PUT | `/quotes/{id}/submit` | Submit quote |
| PUT | `/quotes/{id}/approve` | Approve quote |
| PUT | `/quotes/{id}/issue` | Issue quote |
| GET | `/quotes/{id}` | Get quote details |
| GET | `/quotes` | List all quotes |

### Quote Status Flow

```
DRAFT → SUBMITTED → APPROVED → ISSUED
```

Only valid transitions allowed. All mandatory fields must be present.

## ✅ Assertions Included

- **Status Codes**: 201 (created), 200 (success), 400 (validation), 404 (not found), 409 (conflict)
- **Response Structure**: All required fields present in response
- **Data Validation**: Email formats, date formats, numeric ranges
- **Lifecycle Correctness**: State transitions follow business rules
- **Data Integrity**: Persisted data matches request payload
- **Timestamps**: In chronological order (created < submitted < approved < issued)
- **Fail-Fast Logic**: Tests stop on first failure to save time

## 🔧 Customization

### Add New Test Cases

1. Open `collections/insurance-enterprise.json` in Postman
2. Add new request with pre-request scripts and tests
3. Save and export as JSON
4. Commit and push changes

### Modify Test Data

Edit `data/test-data.csv` with your test scenarios. Format:
```csv
clientId,clientName,clientEmail,...
CL001,John Doe,john.doe@example.com,...
```

### Update Environment Variables

Edit `collections/insurance-env.json` to add/modify variables:
```json
{
  "key": "newVariable",
  "value": "newValue",
  "enabled": true
}
```

## 📦 CI/CD Integration

### GitHub Actions

The `.github/workflows/api-tests.yml` workflow:

- ✅ Runs on push to main/develop
- ✅ Runs on pull requests
- ✅ Daily scheduled runs (2 AM UTC)
- ✅ Automatic matrix testing (Node 18, 20)
- ✅ Uploads HTML and JSON reports
- ✅ Comments PR with test results
- ✅ Fail-fast on test failures

### Usage

1. Push this project to GitHub
2. GitHub Actions automatically runs tests on push/PR
3. View test reports in Artifacts
4. PR comments show test results

## 🐛 Troubleshooting

### Newman not found
```bash
npm install -g newman
```

### Port already in use
```bash
# Change baseUrl in environment file
"value": "http://localhost:8081"
```

### Tests fail with "Cannot POST"
- Ensure Insurance PAS API is running
- Verify `baseUrl` in environment file is correct
- Check API is listening on configured port

### HTML report not generated
```bash
npm install -g newman-reporter-html
```

### Permission denied on run-tests.sh
```bash
chmod +x scripts/run-tests.sh
```

## 📚 Best Practices Implemented

✅ **Fail-Fast Logic** - Tests stop on first failure  
✅ **Comprehensive Assertions** - Status, structure, data integrity  
✅ **Parameterized Testing** - Variables for easy environment switching  
✅ **State Machine Testing** - Invalid transitions caught  
✅ **Data Persistence** - Cross-request data verification  
✅ **Edge Case Coverage** - 404s, validation errors, business rules  
✅ **Clear Test Organization** - Grouped by scenario (happy path, validation, etc.)  
✅ **Meaningful Assertions** - Each test validates specific behavior  
✅ **Reusable Components** - Environment variables, test data CSV  
✅ **CI/CD Ready** - GitHub Actions workflow included  

## 📞 Support

For issues or questions:
1. Check logs in generated reports
2. Verify API is running and responsive
3. Review test assertions in collection
4. Check GitHub Actions logs for CI/CD issues

## 📄 License

Internal use for Insurance PAS testing

---

**Last Updated**: April 2026  
**Collection Version**: 1.0  
**API Target**: Insurance PAS v1.0
