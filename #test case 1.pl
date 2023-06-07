loss(01).
cause_of_loss(01, fire).
repair_plan(01, none).
estimate_pd_claim(01, 16000000).
estimate_bi_claim(01, 3000000).
estimate_ee_claim(01, 25000000).
business_interruption_duration(01, 18).
covers_loss(101, 01).
policy_type(101, iar).
pd_deductible(101, 500000).
bi_deductible(101, 30).
pd_bi_limit(101, 250000000).
ee_limit(101, 25000000).
sublimit_for_cause(101, earthquake, 50000000).
acme_insures_share(101, 0.07).
acme_slip_differs(101, true).
difference_adverse_impact(01, true).
other_policies_covering_loss(01, true).






% Rule 1: It is necessary that an Insured purchases one or more Policies.
% applicable_policy(InsuredID, PolicyID). % important is to relate the insured to the policy, but I think better is to relate the loss to the policy.

% Rule 1.1: It is necessary for a Loss to relate to a Policy.
% covers_loss(PolicyID, LossID). % I think this is a fact, not a rule

% Rule 2: It is necessary that a Policy insure one or more Insured.
% maybe remove this rule? It is formalized in Rule 1, isnt it? We can simplify the one or more insureds since this has to do with subsidiary companies or subcontractors and not core for the project

% Rule 3: It is possible that a Policy is an aggregate one or more Slips.
aggregate_policy(PolicyID, SlipID).


% Rule 4: It is necessary that Slip is written by one Insurer.
writes_slip(InsurerID, SlipID). % need to connect insurer and slip

% Rule 4.1: It is necessary that an Insurer that writes a slip on a policy insure the Insured.
% insure(InsurerID, PolicyID, InsuredID) :- writes_slip(InsurerID, SlipID), aggregate_policy(PolicyID, SlipID), applicable_policy(InsuredID, PolicyID).
% I dont think it matters? Too much informtion about non-Acme insurers

% Rule 5: It is necessary that an Insurer writes a Slip.
% insurer_writes_slip(SlipId, InsurerId) :- slip(SlipId), insurer(InsurerId).
% saying the referse of Rule 4

% Rule 6: It is possible for a Slip to contain one or more Endorsements.
% slip_contains_endorsements(SlipId, EndorsementIds) :- slip(SlipId), findall(EndorsementId, endorsement(EndorsementId), EndorsementIds).
% We dont actually use endorsements outside of this rule.

% Rule 7: It is necessary for one or more Insurer to belong to a Market.
% insurer_belongs_to_market(InsurerId, MarketId) :- insurer(InsurerId), market(MarketId).
% market(InsurerID, policyID) :- writes_slip(InsurerID, SlipID), aggregate_policy(PolicyID, SlipID).


% Rule 8: It is possible for an Insurer to belong to more than one Market.
% insurer_belongs_to_markets(InsurerId, MarketIds) :- insurer(InsurerId), findall(MarketId, market(MarketId), MarketIds).
% I think the PolicyID is a better figure than using creating a MarketID, since every PolicyID will have one MarketID, and vice-versa



% Rule 9: It is necessary for a Policy to be written by only one Market.
% written_by_market(PolicyId, MarketId) :- policy(PolicyId), market(MarketId).


% Rule 10: It is necessary for a Market to write only one Policy.
% market_writes_policy(MarketId, PolicyId) :- market(MarketId), policy(PolicyId).

% Rule 11: It is necessary for a Policy to provide one or more Coverages.
% provides_coverage(PolicyId, CoverageIds) :- policy(PolicyId), findall(CoverageId, coverage(CoverageId), CoverageIds).
provides_coverage(PolicyID, pd). % always true
% provides_coverage(PolicyID, bi) :- provides_coverage(PolicyID, ee). % if it provides EE, it provides BI
% provides_coverage(PolicyID, ee) :- provides_coverage(PolicyID, bi). % vice-versa
% recursion issue, like friends mutuality in exercise

% Rule 12: It is obligatory that a Coverage be limited by one or more Limits.
% coverage_has_limit(CoverageId, LimitIds) :- coverage(CoverageId), findall(LimitId, limit(LimitId), LimitIds).
% provides_coverage(PolicyID, pd) :- pd_bi_limit(PolicyID, PD_Limit). % we already set to always true
provides_coverage(PolicyID, ee) :- ee_limit(PolicyID, EELimit).
provides_coverage(PolicyID, bi) :- ee_limit(PolicyID, EELimit). % if coverage for EE, coverage for BI


% Rule 13: It is necessary for a Coverage to pay after one or more Deductibles.
% coverage_pays_after_deductible(CoverageId, DeductibleIds) :- coverage(CoverageId), findall(DeductibleId, deductible(DeductibleId), DeductibleIds).
claim_after_deductible(LossID, Net_Claim, pd) :- covers_loss(PolicyID, LossID), 
provides_coverage(PolicyID, pd),
estimate_pd_claim(LossID, EstimatedPDClaim),
pd_deductible(PolicyId, PDDeductible),
Net_Claim is EstimatedPDClaim - PDDeductible.

claim_after_deductible(LossID, Net_Claim, bi) :- covers_loss(PolicyID, LossID), 
provides_coverage(PolicyID, bi),
estimate_bi_claim(LossID, EstimatedBIClaim),
bi_deductible(PolicyID, BI_Waiting_Period),
business_interruption_duration(LossID, NumberOfMonths),
Net_Claim is (NumberOfMonths - (BI_Waiting_Period / 30)) * EstimatedBIClaim.
