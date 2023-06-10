loss(01).
policy(10101).
slip(101).

% loss related facts
cause_of_loss(01, fire).
repair_plan(01, none).
estimate_pd_claim(01, 16000000).
estimate_bi_claim(01, 3000000).
estimate_ee_claim(01, 25000000).
business_interruption_duration(01, 18).

% policy related facts
applicable_policy(10101, 101).
covers_loss(10101, 01).
policy_type(10101, iar).
pd_deductible(10101, 500000).
bi_deductible(10101, 30).
pd_bi_limit(10101, 250000000).
ee_limit(10101, 25000000).
exclusion(10101, war).

% slip related facts
sublimit(101, bi, 2000000). 
sublimit(101, earthquake, 50000000).
acme_insures_share(101, 0.07).
% acme_slip_differs(101, true). %this needs to be a rule
% difference_adverse_impact(101, 01, true). % this needs to be a rule
other_policies_covering_loss(01, true).






% Rule 1: It is necessary that an Insured purchases one or more Policies.
applicable_policy(PolicyID, SlipID). % important is to relate the insured to the policy, but I think better is to relate the loss to the policy.

% Rule 1.1: It is necessary for a Loss to relate to a Policy.
covers_loss(PolicyID, LossID). % I think this is a fact, not a rule

% Rule 2: It is necessary that a Policy insure one or more Insured.
% maybe remove this rule? It is formalized in Rule 1, isnt it? We can simplify the one or more insureds since this has to do with subsidiary companies or subcontractors and not core for the project

% Rule 3: It is possible that a Policy is an aggregate one or more Slips.
% aggregate_policy(PolicyID, SlipID).
% Rule 1 already covers this


% Rule 4: It is necessary that Slip is written by one Insurer.
% writes_slip(InsurerID, SlipID). % need to connect insurer and slip
% Rule 1 sufficient

% Rule 4.1: It is necessary that an Insurer that writes a slip on a policy insure the Insured.
% insure(InsurerID, PolicyID, InsuredID) :- writes_slip(InsurerID, SlipID), aggregate_policy(PolicyID, SlipID), applicable_policy(InsuredID, PolicyID).
% I dont think it matters? Too much informtion about non-Acme insurers
% could write a rule to translate a slip->policy relationship into a slip-> insured or -> loss, but necessary?

% Rule 5: It is necessary that an Insurer writes a Slip.
% insurer_writes_slip(SlipId, InsurerId) :- slip(SlipId), insurer(InsurerId).
% saying the referse of Rule 4

% Rule 6: It is possible for a Slip to contain one or more Endorsements.
% slip_contains_endorsements(SlipId, EndorsementIds) :- slip(SlipId), findall(EndorsementId, endorsement(EndorsementId), EndorsementIds).
% We dont actually use endorsements outside of this rule. Maybe say that the slip can be different from the policy.




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


% Rule 14: It is possible for a Policy to exclude one or more Exclusions.
exclusion(PolicyID, Cause).

% Rule 15: It is possible for two Exclusions of the same Slip to be different from each other.
% Rule 14 takes care of this.

% Rule 16: It is possible for two Deductibles of the same Slip to vary from each other.
pd_deductible(PolicyID, Amount).
bi_deductible(PolicyID, Days).
% Something like the following could be a solution 
% deductibles_vary(SlipId, DeductibleId1, DeductibleId2) :- slip(SlipId), deductible(DeductibleId1), deductible(DeductibleId2), DeductibleId1 \= DeductibleId2.

% Rule 17: It is possible for two Limits of the same Slip to be distinct from each other.
% limits_are_distinct(SlipId, LimitId1, LimitId2) :- slip(SlipId), limit(LimitId1), limit(LimitId2), LimitId1 \\= LimitId2.
sublimit(SlipID, bi, Amount). % bi can have a sublimit. It is expressed in an amount per month.
sublimit(SlipID, Cause, Amount). % There can also be sublimits for causes of the loss.


% Rule 18: It is possible for a Policy to be of type CAR.
policy_type(PolicyID, car).

% Rule 19: It is possible for a Policy to be of type IAR.
policy_type(PolicyID, iar).

% Rule 20: It is forbidden for a Policy to appear of type CAR and IAR at the same time.\
policy_type(PolicyID, car) :- \+ policy_type(PolicyID, iar).
policy_type(PolicyID, iar) :- \+ policy_type(PolicyID, car).


% Rule 21: It is necessary for a Slip to provide Coverage for Property Damage (PD).
%provides_pd_coverage(SlipId) :- slip(SlipId), coverage(SlipId, pd).
% I think maybe it should be on the policy? Or both on the policy and the slip, then take the slip if there is a limit?
provides_coverage(SlipID, pd). % always true

% Rule 22: It is possible for a Slip to provide Coverage for Business Interruption (BI).
provides_bi_coverage(SlipId) :- slip(SlipId), coverage(SlipId, bi).
provides_coverage(SlipID, bi) :- provides_coverage(PolicyID, bi), applicable_policy(PolicyID, SlipID).



% Rule 23: It is possible for a Slip to provide Coverage for Extra Expenses (EE).
provides_ee_coverage(SlipId) :- slip(SlipId), coverage(SlipId, ee).
provides_coverage(SlipID, ee) :- provides_coverage(PolicyID, ee), applicable_policy(PolicyID, SlipID).

% Rule 24: If and only if a Policy provides Coverage for BI, it is obligatory that the Policy provides Coverage for EE.
provides_ee_coverage(PolicyId) :- provides_bi_coverage(PolicyId).


% Rule 25: It is permitted for a Policy to be of any type to give Coverage for BI.\
% provides_bi_coverage(PolicyId) :- policy(PolicyId).\
% Rule 12 handles this?

% Rule 26: It is necessary for each Slip to share a Share of the Policy.
share(SlipID, Percent), applicable_policy(PolicyID, SlipID).

% need a loss share number to calculate Acme's share.

% Rule 27: It is obligatory for the Deductible to be either a PD-Deductible or a BI-Deductible.\
deductible_type(DeductibleId, Type) :- deductible(DeductibleId), member(Type, [pd, bi]).\
\
% Rule 28: It is obligatory for the BI-Deductible to be formatted an integer.\
deductible_format(DeductibleId) :- deductible(DeductibleId), deductible_type(DeductibleId, bi), integer(DeductibleId).\
\
% Rule 29: It is obligatory for BI-Deductible to be expressed in number of days.\
bi_deductible_days(DeductibleId, Days) :- deductible(DeductibleId), deductible_type(DeductibleId, bi), integer(Days).\
\
% Rule 30: It is possible for the BI-Deductible to be first 15 days of the Loss.\
bi_deductible_days(DeductibleId, 15).\
\
% Rule 31: It is possible for the BI-Deductible to be first 30 days of the Loss.
bi_deductible_days(DeductibleId, 30).

% Rule 33: It is possible for the BI-Deductible to be 15 times the average daily Loss.
bi_deductible_amount(DeductibleId, DeductibleAmount) :- bi_deductible_days(DeductibleId, Days), Days is 15 * Average, average_daily_loss(Average).

% Rule 34: It is obligatory for an Insured to pay a Deductible before the Insurer pays the Claim.
% We should add a "deductible_pay_date" in the definition of a Deductible? And then say Deductible_pay_date > Claim_pay_date.

% Rule 35: It is permitted for a Deductible to be a Per-Claim Deductible.
deductible_type(DeductibleId, Per_Claim_Deductible).

% Rule 36: It is forbidden for the Insurer to grant Coverage for any Claim lower than the Per-Claim Deductible.
% Rule 37: It is obligatory for the Insurer to offer Coverage for any Claim higher than the Per-Claim Deductible.
% This can be translated to: the Claim Coverage must be higher than the Per-Claim Deductible.
claim_after_deductible(LossID, Net_Claim, bi) :- bi_deductible_amount(DeductibleId, Per_Claim_Deductible_Amount), Net_Claim > Per_Claim_Deductible_Amount. 

% Rule 38: It is permitted for a Deductible to be an Aggregate Deductible.
deductible_type(DeductibleId, Aggregate_Deductible).

% Rule 39: It is obligatory for the Insurer to provide Coverage for a Claim if and only if the Deductible is Satisfied.
coverage_claim(InsurerId, ClaimId) :- claim(ClaimId), deductible_satisfied(DeductibleId). % not sure about this one

% Rule 40: A Per-Claim Deductible is Satisfied if the Claim is for a higher amount than the Per-Claim Deductible.
% I believe Rules 36 and 37 already satisfy this condition. Or we can do something like:
per_claim_deductible_deductible_satisied(DeductibleId) :- deductible_type(DeductibleId, Per_Claim_Deductible), 
bi_deductible_amount(DeductibleId, Per_Claim_Deductible_Amount), 
claim_after_deductible(LossID, Net_Claim, bi), 
Net_Claim > Per_Claim_Deductible_Amount. 

% Rule 41: An Aggregate Deductible is Satisfied if the sum of the amounts of all Claims on the Policy is for a higher amount than the Aggregate Deductible.
% Not sure how to do a sum. Found this on StackOverflow:
% list_sum_claims([],0).
% list_sum_claims([Head|Tail], TotalSum) :- list_sum_claims(Tail, Sum1), TotalSum is Head+Sum1.
aggregate_deductible_satisied(DeductibleId) :- Net_Claim_Sum(Net_Claim), bi_deductible_amount(DeductibleId, Aggregate_Deductible_Amount), Net_Claim_Sum > Aggregate_Deductible_Amount.

% Rule 42: It is necessary for an Insured to file one or more Claims.
file_claim(InsurerId, ClaimId) :- insurer(InsurerId), claim(ClaimId).

% Rule 43: It is possible for a Claim to be covered by Coverage of one or more Policies.
coverage_claim(ClaimId, PolicyId) :- claim(ClaimId), policy(PolicyId).

% Rule 44: It is necessary for a Loss to present as an event.
eventId(LossId).

% Rule 45: It is obligatory for a Claim to be examined by one or more Experts.
% Rule 46: It is obligatory that an Expert examines the Claim.
examines_claim(ExpertId, ClaimId) :- expert(ExpertId), claim(ClaimId).

% Rule 47: It is permitted for the Coverage to be limited by a Limit due to the Cause of Loss.  
 

% Rule 48: It is permitted for the Slip to provide no Coverage for a Claim due to the Cause of Loss.  
% Can we say that the net_claim has to be zero?
