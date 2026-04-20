# Backend Static Analysis Report
**Insurance Policy Administration System (PAS)**
**Analysis Date:** April 20, 2026
**Project Path:** D:\Insurance Project\src\main\java\com\insurance

---

## 1. ENDPOINT MAP

| # | Method | Endpoint | Request DTO | Response DTO | File Reference |
|----|--------|----------|-------------|--------------|-----------------|
| 1 | POST | /agents | CreateAgentRequest | AgentResponse | AgentController.java:39-41 |
| 2 | GET | /agents | - (params) | PagedAgentResponse | AgentController.java:43-48 |
| 3 | GET | /agents/{id} | - | AgentResponse | AgentController.java:50-52 |
| 4 | PUT | /agents/{id} | UpdateAgentRequest | AgentResponse | AgentController.java:54-56 |
| 5 | PATCH | /agents/{id}/status | UpdateAgentStatusRequest | AgentResponse | AgentController.java:58-61 |
| 6 | DELETE | /agents/{id} | - | - | AgentController.java:68-70 |
| 7 | POST | /clients | CreateClientRequest | ClientResponse | ClientController.java:35-37 |
| 8 | GET | /clients | - (params) | PagedClientResponse | ClientController.java:39-48 |
| 9 | GET | /clients/{id} | - | ClientResponse | ClientController.java:50-52 |
| 10 | PUT | /clients/{id} | UpdateClientRequest | ClientResponse | ClientController.java:54-56 |
| 11 | PATCH | /clients/{id} | PatchClientRequest | ClientResponse | ClientController.java:58-60 |
| 12 | PATCH | /clients/{id}/status | UpdateClientStatusRequest | ClientResponse | ClientController.java:62-65 |
| 13 | DELETE | /clients/{id} | - | - | ClientController.java:67-69 |
| 14 | POST | /quotes | CreateQuoteRequest | QuoteResponse | QuoteController.java:32-34 |
| 15 | GET | /quotes/{id} | - | QuoteResponse | QuoteController.java:36-38 |
| 16 | POST | /quotes/{id}/insured-persons | CreateInsuredPersonRequest | InsuredPersonResponse | QuoteController.java:40-44 |
| 17 | GET | /quotes/{id}/insured-persons | - | List[InsuredPersonResponse] | QuoteController.java:46-48 |
| 18 | POST | /quotes/{id}/covers | CreateCoverRequest | CoverResponse | QuoteController.java:50-54 |
| 19 | GET | /quotes/{id}/covers | - | List[CoverResponse] | QuoteController.java:56-58 |
| 20 | GET | /quotes/{id}/cover-tree | - | List[CoverTreeNodeResponse] | QuoteController.java:60-62 |
| 21 | PATCH | /quotes/{id}/status | UpdateQuoteStatusRequest | QuoteResponse | QuoteController.java:64-68 |
| 22 | POST | /covers/{id}/attributes | CoverAttributeRequest | CoverAttributeResponse | CoverAttributeController.java:31-35 |
| 23 | GET | /covers/{id}/attributes | - | List[CoverAttributeResponse] | CoverAttributeController.java:37-39 |
| 24 | GET | /covers/{id} | - | CoverResponse | CoverAttributeController.java:41-43 |
| 25 | PUT | /covers/{id} | UpdateCoverRequest | CoverResponse | CoverAttributeController.java:45-48 |
| 26 | DELETE | /covers/{id} | - | - | CoverAttributeController.java:50-53 |

---

## 2. DTO DEFINITIONS (From Source Code)

### 2.1 Agent DTOs

#### CreateAgentRequest
**File:** `agent/dto/CreateAgentRequest.java`
| Field | Type | Required | Constraints | Notes |
|-------|------|----------|-------------|-------|
| name | String | ✅ | @NotBlank, max 120 chars | @Size validation |
| email | String | ✅ | @NotBlank @Email, max 150 chars | Valid email format required |
| phoneNumber | String | ✅ | @NotBlank, max 30 chars | Phone format flexible |
| role | AgentRole enum | ✅ | @NotNull | See Enum section |
| parentAgentId | Long | ❌ | Optional | For hierarchical agents |

#### AgentResponse
**File:** `agent/dto/AgentResponse.java`
| Field | Type | Returned |
|-------|------|----------|
| id | Long | ✅ |
| name | String | ✅ |
| email | String | ✅ |
| phoneNumber | String | ✅ |
| role | AgentRole | ✅ |
| status | AgentStatus | ✅ |
| parentAgentId | Long | if exists |

---

### 2.2 Client DTOs

#### CreateClientRequest
**File:** `client/dto/CreateClientRequest.java`
| Field | Type | Required | Constraints | Notes |
|-------|------|----------|-------------|-------|
| firstName | String | ✅ | @NotBlank, max 80 chars | |
| lastName | String | ✅ | @NotBlank, max 80 chars | |
| preferredName | String | ❌ | max 80 chars | |
| title | String | ❌ | max 20 chars | |
| maidenName | String | ❌ | max 80 chars | |
| smokerStatus | String | ❌ | max 30 chars | Free text (no enum validation at DTO level) |
| occupation | String | ❌ | max 120 chars | |
| clientType | String | ❌ | max 30 chars | Expected to match predefined types (INDIVIDUAL, etc.) |
| idType | String | ❌ | max 30 chars | Expected to match predefined types (AADHAAR, etc.) |
| externalReference | String | ❌ | max 100 chars | |
| suppressLetters | Boolean | ❌ | Optional | |
| dateOfBirth | LocalDate | ✅ | @NotNull | Date required |
| gender | ClientGender enum | ✅ | @NotNull | See Enum section |
| email | String | ✅ | @NotBlank @Email, max 150 chars | Valid email format required |
| phoneNumber | String | ✅ | @NotBlank, max 30 chars | |
| agentId | Long | ✅ | @NotNull | Must be numeric, references Agent |
| addresses | List[AddressRequest] | ✅ | @NotEmpty @Valid | At least 1 address required |

#### AddressRequest (nested in CreateClientRequest)
**File:** `client/dto/AddressRequest.java`
| Field | Type | Required | Constraints | Notes |
|-------|------|----------|-------------|-------|
| line1 | String | ❌ | max 200 chars | Address line 1 |
| streetAddress | String | ❌ | max 200 chars | Alternative street address |
| line2 | String | ❌ | max 200 chars | Address line 2 |
| city | String | ❌ | max 100 chars | |
| townCity | String | ❌ | max 100 chars | Alternative city field |
| state | String | ❌ | max 100 chars | |
| province | String | ❌ | max 100 chars | Alternative state field |
| country | String | ❌ | max 100 chars | |
| postalCode | String | ❌ | max 20 chars | |
| addressType | AddressType enum | ✅ | @NotNull | PERMANENT or COMMUNICATION |
| isMainAddress | Boolean | ❌ | Optional | |

#### ClientResponse
**File:** `client/dto/ClientResponse.java`
| Field | Type | Returned | Notes |
|-------|------|----------|-------|
| clientId | Long | ✅ | Assigned by backend |
| clientCode | String | ✅ | Auto-generated |
| name | String | ✅ | Combined display |
| preferredName | String | if exists | |
| title | String | if exists | |
| maidenName | String | if exists | |
| smokerStatus | String | if set | |
| occupation | String | if set | |
| clientType | String | ✅ | |
| idType | String | ✅ | |
| externalReference | String | if set | |
| suppressLetters | Boolean | ✅ | |
| email | String | ✅ | |
| phoneNumber | String | ✅ | |
| status | ClientStatus | ✅ | ACTIVE or INACTIVE |
| agentId | Long | ✅ | Numeric, references agent |
| addresses | List[AddressResponse] | ✅ | |
| contacts | List[ContactResponse] | if exists | |

---

### 2.3 Quote DTOs

#### CreateQuoteRequest
**File:** `quote/dto/CreateQuoteRequest.java`
| Field | Type | Required | Constraints | Notes |
|-------|------|----------|-------------|-------|
| clientId | Long | ✅ | @NotNull | Numeric, references Client |
| agentId | Long | ✅ | @NotNull | Numeric, references Agent |

#### QuoteResponse
**File:** `quote/dto/QuoteResponse.java`
| Field | Type | Returned | Notes |
|-------|------|----------|-------|
| quoteId | Long | ✅ | Assigned by backend |
| quoteNumber | String | ✅ | Auto-generated: "Q-{timestamp}-{uuid}" |
| clientId | Long | ✅ | |
| agentId | Long | ✅ | |
| status | QuoteStatus enum | ✅ | DRAFT, SUBMITTED, QUOTED, APPROVED, OFFER, ACCEPTED, ISSUED |
| insuredPersons | List[InsuredPersonResponse] | ✅ | |
| covers | List[CoverResponse] | ✅ | |

#### UpdateQuoteStatusRequest
**File:** `quote/dto/UpdateQuoteStatusRequest.java`
| Field | Type | Required |
|-------|------|----------|
| status | QuoteStatus enum | ✅ |

---

### 2.4 Insured Person DTOs

#### CreateInsuredPersonRequest
**File:** `quote/dto/CreateInsuredPersonRequest.java`
| Field | Type | Required | Constraints | Notes |
|-------|------|----------|-------------|-------|
| clientId | Long | ✅ | @NotNull | Numeric, references Client |
| role | InsuredRole enum | ✅ | @NotNull | PRIMARY, SECONDARY, or CHILD |
| isPrimary | Boolean | ❌ | Optional | Flag to mark as primary insured |

#### InsuredPersonResponse
**File:** `quote/dto/InsuredPersonResponse.java`
| Field | Type | Returned | Notes |
|-------|------|----------|-------|
| insuredId | Long | ✅ | Assigned by backend |
| quoteId | Long | ✅ | |
| clientId | Long | ✅ | |
| role | InsuredRole | ✅ | |
| isPrimary | Boolean | ✅ | |

---

### 2.5 Cover DTOs

#### CreateCoverRequest
**File:** `quote/dto/CreateCoverRequest.java`
| Field | Type | Required | Constraints | Notes |
|-------|------|----------|-------------|-------|
| insuredId | Long | ✅ | @NotNull | Numeric, references InsuredPerson |
| parentCoverId | Long | ❌ | Optional | For RIDER covers only |
| coverCode | String | ✅ | @NotBlank | e.g., "LC" |
| coverName | String | ✅ | @NotBlank | e.g., "Life Cover" |
| coverType | CoverType enum | ✅ | @NotNull | BASE or RIDER |
| sumAssured | BigDecimal | ✅ | @DecimalMin("0.01") | Must be > 0 |
| calculatedSumAssured | BigDecimal | ❌ | Optional | |
| benefitAmount | BigDecimal | ❌ | Optional | |
| premium | BigDecimal | ❌ | Optional | Can be auto-calculated |
| annualPremium | BigDecimal | ❌ | Optional | Can be auto-calculated |
| premiumTermYears | Integer | ❌ | Optional | |
| premiumTermAge | Integer | ❌ | Optional | |
| premiumTermDate | LocalDate | ❌ | Optional | |
| premiumRateBasis | String | ❌ | Optional | |
| termYears | Integer | ❌ | Optional | Years of term |
| termMonths | Integer | ❌ | Optional | Months of term |
| termDays | Integer | ❌ | Optional | Days of term |
| commencementDate | LocalDate | ✅ | @NotNull | Start date |
| termEndDate | LocalDate | ❌ | Optional | End date (auto-calculated if not provided) |
| indexationEnabled | Boolean | ❌ | Optional | |
| indexType | String | ❌ | Optional | |
| benefitEscalationType | String | ❌ | Optional | |
| smokerStatus | String | ❌ | Optional | Can be set here or via attributes |
| occupationClass | String | ❌ | Optional | Can be set here or via attributes |
| rateableAge | Integer | ❌ | Optional | Can be set here or via attributes |
| boosterPercentage | BigDecimal | ❌ | Optional | |
| income | BigDecimal | ❌ | Optional | |
| mortgage | BigDecimal | ❌ | Optional | |
| taxInfo | String | ❌ | Optional | |

#### UpdateCoverRequest
**File:** `quote/dto/UpdateCoverRequest.java`
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| insuredId | Long | ❌ | Can reassign cover to different insured |
| coverName | String | ❌ | |
| sumAssured | BigDecimal | ❌ | |
| calculatedSumAssured | BigDecimal | ❌ | |
| benefitAmount | BigDecimal | ❌ | |
| premium | BigDecimal | ❌ | |
| annualPremium | BigDecimal | ❌ | |
| premiumTermYears | Integer | ❌ | |
| premiumTermAge | Integer | ❌ | |
| premiumTermDate | LocalDate | ❌ | |
| premiumRateBasis | String | ❌ | |
| termYears | Integer | ❌ | |
| termMonths | Integer | ❌ | |
| termDays | Integer | ❌ | |
| commencementDate | LocalDate | ❌ | |
| termEndDate | LocalDate | ❌ | |
| indexationEnabled | Boolean | ❌ | |
| indexType | String | ❌ | |
| benefitEscalationType | String | ❌ | |
| smokerStatus | String | ❌ | **CRITICAL: triggers required attribute validation if CoverConfig specifies** |
| occupationClass | String | ❌ | **CRITICAL: triggers required attribute validation if CoverConfig specifies** |
| rateableAge | Integer | ❌ | **CRITICAL: triggers required attribute validation if CoverConfig specifies** |
| boosterPercentage | BigDecimal | ❌ | |
| income | BigDecimal | ❌ | |
| mortgage | BigDecimal | ❌ | |
| taxInfo | String | ❌ | |

#### CoverResponse
**File:** `quote/dto/CoverResponse.java`
| Field | Type | Returned | Notes |
|-------|------|----------|-------|
| coverId | Long | ✅ | Assigned by backend |
| quoteId | Long | ✅ | |
| insuredId | Long | ✅ | |
| parentCoverId | Long | if exists | |
| coverCode | String | ✅ | |
| coverName | String | ✅ | |
| coverType | CoverType | ✅ | BASE or RIDER |
| status | CoverStatus | ✅ | Always "QUOTE" on creation |
| sumAssured | BigDecimal | ✅ | |
| [all other fields] | [various] | ✅ | All fields from request returned |
| attributes | List[CoverAttributeResponse] | ✅ | Nested list of attributes |

---

### 2.6 Cover Attribute DTOs

#### CoverAttributeRequest
**File:** `quote/dto/CoverAttributeRequest.java`
| Field | Type | Required | Constraints | Notes |
|-------|------|----------|-------------|-------|
| attributeKey | String | ✅ | @NotBlank | Case-normalized to lowercase on storage |
| valueType | CoverAttributeValueType enum | ✅ | @NotNull | STRING, NUMBER, or BOOLEAN |
| stringValue | String | ❌* | *if valueType=STRING | Must be non-blank if provided |
| numberValue | BigDecimal | ❌* | *if valueType=NUMBER | |
| booleanValue | Boolean | ❌* | *if valueType=BOOLEAN | |

**CRITICAL VALIDATION RULE** (from validateAttributePayload):
- **Exactly ONE** of {stringValue, numberValue, booleanValue} must be set
- The selected value must match the valueType
- Example: If valueType=STRING, stringValue must be provided and others null

#### CoverAttributeResponse
**File:** `quote/dto/CoverAttributeResponse.java`
| Field | Type | Returned | Notes |
|-------|------|----------|-------|
| id | Long | ✅ | |
| attributeKey | String | ✅ | Stored in lowercase |
| valueType | CoverAttributeValueType | ✅ | |
| stringValue | String | if set | |
| numberValue | BigDecimal | if set | |
| booleanValue | Boolean | if set | |

---

## 3. ENUM VALUES (From Source Code)

### 3.1 Agent Enums

#### AgentRole
**File:** `agent/model/AgentRole.java`
```
- AGENT
- MANAGER
- ADMIN
```

#### AgentStatus
**File:** `agent/model/AgentStatus.java`
```
- ACTIVE
- INACTIVE
- SUSPENDED
```

**BUSINESS RULE:** Only ACTIVE agents can be referenced when creating Quotes/Clients
(Source: QuoteServiceImpl:513 - `fetchActiveAgent()`)

---

### 3.2 Client Enums

#### ClientGender
**File:** `client/model/ClientGender.java`
```
- MALE
- FEMALE
- OTHER
```
**Usage:** Required in CreateClientRequest

#### ClientStatus
**File:** `client/model/ClientStatus.java`
```
- ACTIVE
- INACTIVE
```

#### AddressType
**File:** `client/model/AddressType.java`
```
- PERMANENT
- COMMUNICATION
```
**Usage:** Required in each AddressRequest

---

### 3.3 Quote Enums

#### QuoteStatus
**File:** `quote/model/QuoteStatus.java`
```
- DRAFT          (initial state on creation)
- SUBMITTED      (after all validations pass)
- QUOTED         (legacy status for backwards compat)
- APPROVED       (after SUBMITTED, subject to strict validations)
- OFFER          (legacy status)
- ACCEPTED       (legacy status)
- ISSUED         (final state after APPROVED)
```

**Valid State Machine:**
```
DRAFT → SUBMITTED → APPROVED → ISSUED
(Legacy: QUOTED, OFFER, ACCEPTED can transition to SUBMITTED)
```

---

### 3.4 Insured/Cover Enums

#### InsuredRole
**File:** `quote/model/InsuredRole.java`
```
- PRIMARY       (main person being insured)
- SECONDARY     (co-insured)
- CHILD         (child/dependent)
```

#### CoverType
**File:** `quote/model/CoverType.java`
```
- BASE          (main cover, must have at least 1 per insured for SUBMIT)
- RIDER         (supplementary cover, requires parentCoverId)
```

#### CoverStatus
**File:** `quote/model/CoverStatus.java`
```
- QUOTE         (only status, covers always start here)
```

#### CoverAttributeValueType
**File:** `quote/model/CoverAttributeValueType.java`
```
- STRING        (text values)
- NUMBER        (numeric values, BigDecimal)
- BOOLEAN       (true/false values)
```

---

## 4. BUSINESS RULES (From Service Layer)

### 4.1 Quote Lifecycle & Status Transitions

**Source:** `QuoteServiceImpl.java` lines 1008-1100

#### ALLOWED_STATUS_TRANSITIONS (Lines 95-99)
```
DRAFT         → SUBMITTED only
SUBMITTED     → APPROVED only
APPROVED      → ISSUED only
ISSUED        → (locked, no transitions)
```

#### Legacy Status Handling (Lines 1003-1005)
- QUOTED, OFFER, ACCEPTED can transition to SUBMITTED (migration path)
- This is for backwards compatibility

#### Quote Immutability Rules (Lines 992-999)
Quotes in these states **CANNOT BE MODIFIED**:
- OFFER
- ACCEPTED
- ISSUED

---

### 4.2 DRAFT → SUBMITTED Transition Validations

**Source:** `QuoteServiceImpl.java` lines 1016-1036

**Rule 1:** At least 1 insured person must exist
```
if (insureds.isEmpty()) {
  throw InvalidRequestException("At least 1 insured person must exist...")
}
```

**Rule 2:** Each insured must have at least 1 BASE cover
```
for (InsuredPerson insured : insureds) {
  if (!hasBase) {
    throw InvalidRequestException("Each insured person must have at least one BASE cover")
  }
}
```

**Rule 3:** Each cover must have positive sumAssured
```
if (sumAssured <= 0) {
  throw InvalidRequestException("sumAssured must be > 0")
}
```

---

### 4.3 SUBMITTED → APPROVED Transition Validations

**Source:** `QuoteServiceImpl.java` lines 1038-1095

#### Rule 1: Waiver of Premium (WOP) is Mandatory for Income Protection
```
boolean hasIncomeProtection = covers.stream().anyMatch(c -> 
  c.getCoverCode().equals("IP") || c.getCoverCode().equals("KPP")
);
if (hasIncomeProtection && !hasWaiverOfPremium) {
  throw InvalidRequestException("WOP cover is strictly mandatory for IP/KPP")
}
```

#### Rule 2: All Covers Must Have Valid Financial Data
```
For each cover:
  - sumAssured must be > 0
  - premium must be >= 0
```

#### Rule 3: Required Attributes Must Exist and Have Values
**CRITICAL - Attribute Validation During SUBMIT:**

```
For each cover:
  1. Get CoverConfig for this cover's coverCode
  2. Read requiredAttributes CSV from CoverConfig
  3. For EACH required attribute name:
     - Attribute must exist in database (case-insensitive match)
     - Attribute value must NOT be null/empty/blank based on type:
       * STRING type: must have stringValue that's not blank
       * NUMBER type: must have numberValue that's not null
       * BOOLEAN type: must have booleanValue that's not null
     - Error message: "Missing required attribute: {name} for cover: {code}"
```

**Source Code (Lines 1060-1090):**
```java
CoverConfig config = fetchCoverConfig(cover.getCoverCode());
Set<String> requiredNames = parseCsvSet(config.getRequiredAttributes());
if (!requiredNames.isEmpty()) {
  List<CoverAttribute> attributes = coverAttributeRepository.findByCoverCoverIdAndIsDeletedFalse(cover.getCoverId());
  
  for (String requiredName : requiredNames) {
    CoverAttribute matchedAttr = attributes.stream()
        .filter(a -> a.getAttributeKey().toLowerCase().equals(requiredName))
        .findFirst()
        .orElse(null);
    
    if (matchedAttr == null) {
      throw InvalidRequestException("Missing required attribute: " + requiredName + "...")
    }
    
    boolean isValueMissing = false;
    switch(matchedAttr.getValueType()) {
      case STRING: isValueMissing = matchedAttr.getStringValue() == null || stringValue.isBlank(); break;
      case NUMBER: isValueMissing = matchedAttr.getNumberValue() == null; break;
      case BOOLEAN: isValueMissing = matchedAttr.getBooleanValue() == null; break;
    }
    if (isValueMissing) {
      throw InvalidRequestException("Required attribute " + requiredName + " must not have null/empty value")
    }
  }
}
```

---

### 4.4 Data Integrity Rules

#### Agent References
- Must exist in database
- Must have AgentStatus = ACTIVE
- Client being quoted must belong to the selected Agent

#### Client References
- Must exist in database
- Must belong to the Agent being referenced in Quote

#### Cover Code Validation
- Must have an entry in CoverConfig table
- CoverType must align with CoverConfig.isBaseCover flag

#### Duplicate BASE Covers
- Cannot have 2 BASE covers with same coverCode for same insured in same quote
- RIDER covers can be duplicated

---

### 4.5 Premium Calculation

**Source:** `QuoteServiceImpl.java` lines 268-289

When adding a cover:
- If premium is NOT provided BUT rateableAge IS provided:
  - Backend calls PremiumCalculationService
  - Calculates premium based on: coverCode, sumAssured, rateableAge, smokerStatus, occupationClass
  - If no rate table found → caller must provide premium manually
- If premium IS provided → use provided value
- If neither rateableAge nor premium provided → store as-is (unknown premium)

---

### 4.6 Cover Update Business Rules

**Source:** `QuoteServiceImpl.java` lines 391-450

- At least 1 field must be provided to trigger an update
- If sumAssured changes: must be > 0
- If premium changes: must be >= 0
- **CRITICAL:** After update, validateRequiredAttributes() is called again
  - If any required attribute becomes missing due to field changes → exception

---

### 4.7 Attribute Validation Rules

#### On Adding Attribute (addCoverAttribute)
**Source:** `QuoteServiceImpl.java` lines 500-543

1. **Duplicate Key Check:**
   - Cannot add attribute with same key (case-insensitive) twice
   - Error: "Duplicate attribute key for cover: {key}"

2. **Payload Validation (validateAttributePayload):**
   - Exactly 1 of {stringValue, numberValue, booleanValue} must be set
   - Value type must match the valueType enum
   - Example: valueType=STRING requires stringValue

3. **After Adding Attribute:**
   - Call validateRequiredAttributes() again
   - If required attribute for cover's coverCode is now missing → exception

#### Attribute Storage Rules
- attributeKey is case-normalized to **lowercase** on storage
- Queries perform case-insensitive matching
- Values are stored as-is (no normalization)
- Example: {"attributeKey": "SmokerStatus"} stored as "smokerstatus"

---

### 4.8 Client/Agent Relationship Rules

- Client must belong to Agent (client.agentId must equal agent.agentId)
- When creating Quote: clientId and agentId must be from same Agent-Client pair
- When adding Insured: insuredClient.agentId must equal quote.agentId

---

## 5. EXECUTION FLOW (Correct Sequence)

### Phase 1: Agent & Client Setup
```
1. POST /agents (create Agent)
   → Returns: agentId (numeric)

2. POST /clients (create Client)
   → Must include: agentId (numeric, not quoted)
   → Must include: firstName, lastName, gender, dateOfBirth, email, phoneNumber
   → Must include: at least 1 address with addressType
   → Returns: clientId (numeric)
```

### Phase 2: Quote Initialization
```
3. POST /quotes (create Quote in DRAFT)
   → Must include: clientId, agentId (both numeric)
   → Returns: quoteId, status=DRAFT

4. POST /quotes/{quoteId}/insured-persons (add Insured)
   → Must include: clientId, role (InsuredRole enum)
   → Returns: insuredId
   → Insured MUST exist in database as Client
```

### Phase 3: Cover Setup
```
5. POST /quotes/{quoteId}/covers (add Cover - BASE type)
   → Must include: insuredId, coverCode, coverName, coverType=BASE
   → Must include: sumAssured (BigDecimal > 0), commencementDate
   → Should include: termYears (if known), rateableAge (for auto-premium calc)
   → Returns: coverId
   → Backend validates via CoverConfig and CoverValidatorEngine

Optional: Add RIDER covers
6. POST /quotes/{quoteId}/covers (add Cover - RIDER type)
   → Must include: insuredId, coverCode, coverName, coverType=RIDER
   → Must include: parentCoverId (references BASE cover)
```

### Phase 4: Attribute Assignment
```
7. POST /covers/{coverId}/attributes (add attribute 1)
   → Must include: attributeKey, valueType, [exact 1 of: stringValue|numberValue|booleanValue]
   → Returns: id, attributeKey (normalized to lowercase)
   → Backend validates: no duplicates, correct payload

8. POST /covers/{coverId}/attributes (add attribute 2)
   → Same as #7

9. POST /covers/{coverId}/attributes (add attribute 3)
   → Same as #7
   → After this, validateRequiredAttributes() called
   → If all required attrs now present → success
```

### Phase 5: Cover Update (OPTIONAL)
```
10. PUT /covers/{coverId} (update Cover with premium + attributes)
    → Can update: benefitAmount, premium, annualPremium, termEndDate
    → Can update: smokerStatus, occupationClass, rateableAge
    → Returns: updated CoverResponse with all fields
    → Backend validates: required attributes still present
```

### Phase 6: Status Transitions
```
11. PATCH /quotes/{quoteId}/status (transition DRAFT → SUBMITTED)
    → Required: status=SUBMITTED in body
    → Validations:
       - At least 1 insured exists
       - Each insured has at least 1 BASE cover
    → Returns: quoteId, status=SUBMITTED

12. PATCH /quotes/{quoteId}/status (transition SUBMITTED → APPROVED)
    → Required: status=APPROVED in body
    → Validations:
       - WOP mandatory if IP/KPP present
       - All covers have positive sumAssured & premium
       - ALL REQUIRED ATTRIBUTES by CoverConfig exist & have values
    → Returns: quoteId, status=APPROVED

13. PATCH /quotes/{quoteId}/status (transition APPROVED → ISSUED)
    → Required: status=ISSUED in body
    → No additional business rule validations at this transition
    → Returns: quoteId, status=ISSUED
```

---

## 6. CRITICAL UNKNOWNS & ASSUMPTIONS

| Item | Status | Notes |
|------|--------|-------|
| CoverConfig.requiredAttributes content | UNKNOWN | Must query database for coverCode=LC to see what attributes are required |
| Valid attribute enum values (occupationClass, smokerStatus) | UNKNOWN | Backend stores as free-text strings, no validation at DTO level |
| Available coverCodes beyond "LC" | UNKNOWN | LC is mentioned, but IP, KPP, WOP exist in service logic |
| Premium calculation algorithm | UNKNOWN | Internal to PremiumCalculationService |
| AddressType COMMUNICATION usage | UNCLEAR | Code supports it but test may not need alternative address |
| Contact API | NOT_ANALYZED | ContactController exists but not relevant to quote flow |
| Underwriting Case API | NOT_ANALYZED | Triggers on SUBMITTED but not part of main QA flow |

---

## 7. KEY DIFFERENCES FROM EARLIER QA COLLECTION

| Item | Earlier Collection | Actual Backend | Impact |
|------|-------------------|-----------------|--------|
| Insured Endpoint | `/quotes/{id}/insured` | `/quotes/{id}/insured-persons` | **ENDPOINT MISMATCH** |
| CreateInsuredPersonRequest | `role`, `isPrimary` | Same | ✅ Matches |
| InsuredRole values | PRIMARY, SECONDARY | PRIMARY, SECONDARY, **CHILD** | Minor (CHILD option available) |
| Cover BASE/RIDER | Yes | Yes | ✅ Matches |
| Attribute Keys | "premium_rate" | No validation, free-text | ❌ Wrong attribute name |
| Required Attributes | "3 required manual" | Config-driven from DB | ❌ Different mechanism |
| PUT /covers/{id} payload | Guessed | Exact spec in UpdateCoverRequest | ✅ Now confirmed |

---

## 8. RECOMMENDED QA COLLECTION UPDATES

1. **Change endpoint:** `/quotes/{id}/insured` → `/quotes/{id}/insured-persons`
2. **Verify CoverConfig:**
   - Query database for coverCode=LC
   - Get actual requiredAttributes (if any)
   - Get applicable fields list
3. **Confirm attribute names:**
   - If business rule requires attributes, use actual CoverConfig.requiredAttributes
   - If SmokerStatus/OccupationClass are required, verify exact enum values
4. **Add agent validation:**
   - Client must belong to Agent
   - All references must be ACTIVE agents
5. **Test all status transitions:**
   - Especially SUBMITTED→APPROVED (strictest validation)
   - Include WOP rule testing

---

**Analysis Complete** ✅
**Collection Ready for Regeneration** ✅
