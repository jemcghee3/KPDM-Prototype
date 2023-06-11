loss(01).
loss(02).
loss(03).
loss(04).
loss(05).
policy(10101).
slip(101).

% loss related facts
cause_of_loss(01, fire). % cause of the loss is fire, earthquake, war, unknown
repair_plan(01, none). % repair plan is none or repair (will this be used?)
estimate_pd_claim(01, 15000000). % estimate of the gross property damage claim
estimate_bi_claim(01, 3000000). % estimate of the gross business interruption claim, per month
estimate_ee_claim(01, 20000000). % estimate of the gross extra expense claim
business_interruption_duration(01, 24). % duration of the business interruption in months
covers_loss(10101, 01). % policy 10101 covers loss 01
examines_claim(sergio, 01). % sergio examines the claim
other_policies_covering_loss(01, true). % this is not used, but should lead to a dispute if it changes Acme's amount by more than 100,000
% should be dispute due to size of the claim over 1 million Acme's share

cause_of_loss(02, earthquake).
repair_plan(02, none).
estimate_pd_claim(02, 15000000).
estimate_bi_claim(02, 3000000).
estimate_ee_claim(02, 20000000).
business_interruption_duration(02, 24).
covers_loss(10101, 02).
examines_claim(sarah, 02). 
examines_claim(sergio, 02).
% should not be a dispute because the sublimit is 5 million, or 4.5million after deductibe, and Acme's share is 7%, or 315,000, and no other factors are present

cause_of_loss(03, war).
repair_plan(03, none).
estimate_pd_claim(03, 15000000).
estimate_bi_claim(03, 3000000).
estimate_ee_claim(03, 20000000).
business_interruption_duration(03, 24).
covers_loss(10101, 03).
examines_claim(james, 03). 
examines_claim(sergio, 03).
% should be a dispute because the sublimit is 0 (the cause is excluded), so by filing a claim, causation is in dispute

cause_of_loss(04, fire).
repair_plan(04, none).
estimate_pd_claim(04, 1000000).
estimate_bi_claim(04, 3000000).
estimate_ee_claim(04, 0).
business_interruption_duration(04, 1).
covers_loss(10101, 04).
examines_claim(sergio, 04).
% should not be a dispute because the claim is 500,000 net of deductible and Acme's share is 7%, or 35,000, and no other factors are present

cause_of_loss(05, unknown).
repair_plan(05, none).
estimate_pd_claim(05, 1000000).
estimate_bi_claim(05, 3000000).
estimate_ee_claim(05, 0).
business_interruption_duration(05, 1).
covers_loss(10101, 05).
examines_claim(sergio, 05).
examines_claim(charlene, 05).
% should be in dispute because cause is unknown and the claim is 500,000 net of deductible and Acme's share is 7%, or 35,000. Charlene is an engineer and can determine the cause of the loss

% policy related facts
applicable_policy(10101, 101). % policy 10101 is applicable to slip 101

policy_type(10101, iar). % policy 10101 is an industrial all risk policy
pd_deductible(10101, 500000). % policy 10101 has a property damage deductible of 500,000
bi_deductible(10101, 30). % policy 10101 has a business interruption deductible of 30 days
pd_bi_limit(10101, 250000000). % policy 10101 has a property damage and business interruption limit of 250,000,000
ee_limit(10101, 25000000). % policy 10101 has an extra expense limit of 25,000,000
sublimit(10101, war, 0). % policy 10101 has a sublimit for war of 0 (that is, a loss is not covered if it is caused by war)

% slip related facts
sublimit(101, bi, 2000000). % slip 101 has a sublimit for business interruption of 2,000,000 (per month)
sublimit(101, earthquake, 5000000). % slip 101 has a sublimit of 5,000,000 if the cause of the loss is earthquake
acme_insures_share(101, 0.07). % Acme insures 7% of the risk under slip 101
% acme_slip_differs(101, true). %this needs to be a rule or removed
% difference_adverse_impact(101, 01, true). % this needs to be a rule or removed

% expert related facts
expert(sergio). % sergio is an expert
expert(sarah).
expert(james).
expert(charlene).
expert_type(sergio, adjuster). % sergio is an adjuster
expert_type(sarah, accountant).
expert_type(james, lawyer).
expert_type(charlene, engineer).




% Rule 1: It is necessary that an Insured purchases one or more Policies.
% This Rule is not formalized because it is not necessary. We did not consider the case where an insured does not purchase a policy.

% Rule 1.1: It is necessary for a Loss to relate to a Policy.
covers_loss(PolicyID, LossID). % I think this is a fact, not a rule

% Rule 2: It is necessary that a Policy insure one or more Insured.
% This Rule is not formalized because it is not necessary. We did not consider the case where a policy does not insure an insured.

% Rule 3: It is possible that a Policy is an aggregate one or more Slips.
applicable_policy(PolicyID, SlipID). % A policy is applicable to a slip, so it is an aggregate policy

% Rule 4: It is necessary that Slip is written by one Insurer.
% This Rule is not formalized because it is not necessary. We considered the slip, the contract document, to be providing the insurance, not the insurer.

% Rule 5: It is necessary that an Insurer writes a Slip.
% This Rule is not formalized because it is not necessary. We considered the slip, the contract document, to be providing the insurance, not the insurer.

% Rule 6: It is possible for a Slip to contain one or more different sublimits from the policy.
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

claim_after_deductible(LossID, Net_Claim, ee) :- covers_loss(PolicyID, LossID),
provides_coverage(PolicyID, ee),
estimate_ee_claim(LossID, Net_Claim).

% Rule 14: It is possible for a Policy to exclude one or more Exclusions.
exclusion(PolicyID, Cause) :- sublimit(PolicyID, Cause, 0).

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


% Rule 25: It is permitted for a Policy to be of any type to give Coverage for BI.
% provides_bi_coverage(PolicyId) :- policy(PolicyId).
% Rule 12 handles this?

% Rule 26: It is necessary for each Slip to share a Share of the Policy.
% isShare(SlipID, PolicyID) :- share(SlipID, Percent), applicable_policy(PolicyID, SlipID).
% do we need to relate this directly to a slip? I do not think so, but this could be a useful shortcut

% Rule 27: It is obligatory for the Deductible to be either a PD-Deductible or a BI-Deductible.
% deductible_type(DeductibleId, Type) :- deductible(DeductibleId), member(Type, [pd, bi]).
pd_deductible(PolicyID, Amount).
bi_deductible(PolicyID, Days).

% Rule 28: It is obligatory for the BI-Deductible to be formatted an integer.
% deductible_format(DeductibleId) :- deductible(DeductibleId), deductible_type(DeductibleId, bi), integer(DeductibleId).
% leave this out

% Rule 29: It is obligatory for BI-Deductible to be expressed in number of days.
% bi_deductible_days(DeductibleId, Days) :- deductible(DeductibleId), deductible_type(DeductibleId, bi), integer(Days).
% leave this out


% Rule 30: It is possible for the BI-Deductible to be first 15 days of the Loss.
% bi_deductible_days(DeductibleId, 15).
% remove

% Rule 31: It is possible for the BI-Deductible to be first 30 days of the Loss.
% bi_deductible_days(DeductibleId, 30).
% remove

% Rule 33: It is possible for the BI-Deductible to be 15 times the average daily Loss.
bi_deductible_amount(DeductibleId, DeductibleAmount) :- bi_deductible_days(DeductibleId, Days), Days is 15 * Average, average_daily_loss(Average).
% does this work? We can also remove

% Rule 34: It is obligatory for an Insured to pay a Deductible before the Insurer pays the Claim.
% We should add a "deductible_pay_date" in the definition of a Deductible? And then say Deductible_pay_date > Claim_pay_date.
% I think we can check if the claim is greater than the deductible
deductibleSatisfied(LossID) :- estimate_pd_claim(LossID, Amount),
covers_loss(PolicyID, LossID),
pd_deductible(PolicyID, Deductible),
Amount > Deductible.

deductibleSatisfied(LossID) :- estimate_bi_claim(LossID, Amount),
covers_loss(PolicyID, LossID),
bi_deductible(PolicyID, Deductible),
Amount > Deductible.


% Rule 35: It is permitted for a Deductible to be a Per-Claim Deductible.
% deductible_type(DeductibleId, Per_Claim_Deductible).

% Rule 36: It is forbidden for the Insurer to grant Coverage for any Claim lower than the Per-Claim Deductible.
% Rule 37: It is obligatory for the Insurer to offer Coverage for any Claim higher than the Per-Claim Deductible.
% This can be translated to: the Claim Coverage must be higher than the Per-Claim Deductible.
% claim_after_deductible(LossID, Net_Claim, bi) :- bi_deductible_amount(DeductibleId, Per_Claim_Deductible_Amount), Net_Claim > Per_Claim_Deductible_Amount. 

% Rule 38: It is permitted for a Deductible to be an Aggregate Deductible.
% deductible_type(DeductibleId, Aggregate_Deductible).

% Rule 39: It is obligatory for the Insurer to provide Coverage for a Claim if and only if the Deductible is Satisfied.
% coverage_claim(InsurerId, ClaimId) :- claim(ClaimId), deductible_satisfied(DeductibleId). % not sure about this one
% Rule 34 handles this, as well as Rule 13.


% Rule 40: A Per-Claim Deductible is Satisfied if the Claim is for a higher amount than the Per-Claim Deductible.
% I believe Rules 36 and 37 already satisfy this condition. Or we can do something like:
% per_claim_deductible_deductible_satisied(DeductibleId) :- deductible_type(DeductibleId, Per_Claim_Deductible), 
% bi_deductible_amount(DeductibleId, Per_Claim_Deductible_Amount), 
% claim_after_deductible(LossID, Net_Claim, bi), 
% Net_Claim > Per_Claim_Deductible_Amount. 

% Rule 41: An Aggregate Deductible is Satisfied if the sum of the amounts of all Claims on the Policy is for a higher amount than the Aggregate Deductible.
% Not sure how to do a sum. Found this on StackOverflow:
% list_sum_claims([],0).
% list_sum_claims([Head|Tail], TotalSum) :- list_sum_claims(Tail, Sum1), TotalSum is Head+Sum1.
% aggregate_deductible_satisied(DeductibleId) :- Net_Claim_Sum(Net_Claim), bi_deductible_amount(DeductibleId, Aggregate_Deductible_Amount), Net_Claim_Sum > Aggregate_Deductible_Amount.

% Rule 42: It is necessary for an Insured to file one or more Claims.
% file_claim(InsurerId, ClaimId) :- insurer(InsurerId), claim(ClaimId).

% Rule 43: It is possible for a Claim to be covered by Coverage of one or more Policies.
% coverage_claim(ClaimId, PolicyId) :- claim(ClaimId), policy(PolicyId).
% Rule 1.1 already covers this use case.

% Rule 44: It is necessary for a Loss to present as an event.
eventId(LossId).

% Rule 45: It is obligatory for a Claim to be examined by one or more Experts.
% Rule 46: It is obligatory that an Expert examines the Claim.
examines_claim(ExpertId, ClaimId). 
% the above says if there is a claim and there is an expert, then the expert examines the claim. But the expert may examine a different claim.
%examines_claim(james, 01).



% Rule 47: It is permitted for the Coverage to be limited by a Limit due to the Cause of Loss.

coverage_limit(LossID, Sublimit) :- covers_loss(PolicyID, LossID),
applicable_policy(PolicyID, SlipID),
pd_bi_limit(PolicyID, Amount),
cause_of_loss(LossID, Cause),
sublimit(SlipID, Cause, Sub),
nonvar(Sub),
Sub < Amount,
Sublimit = Sub.

coverage_limit(LossID, Amount) :- covers_loss(PolicyID, LossID),
pd_bi_limit(PolicyID, Amount).



% Rule 48: It is permitted for the Slip to provide no Coverage for a Claim due to the Cause of Loss.  
% Can we say that the net_claim has to be zero?
% Yes, I think so. Just limit the sublimit amount to zero. Then Rule 47 takes over.

% This section calculates the amount of Acme's share of the claim, in a currency.
acme_share(LossID, Amount) :- 
    claim_after_deductible(LossID, PD_Net_Claim, pd),
    claim_after_deductible(LossID, BI_Net_Claim, bi),
    claim_after_deductible(LossID, EE_Net_Claim, ee),
    covers_loss(PolicyID, LossID),
    applicable_policy(PolicyID, SlipID),
    acme_insures_share(SlipID, Share),
    !, % This cut is needed to avoid an infinite loop
    Amount = Share * (PD_Net_Claim + BI_Net_Claim + EE_Net_Claim).


% Final Rules
no_dispute(LossID) :- 
    acme_share(LossID, Amount), 
    Amount < 10000,
    Amount > 0.
    % If Acme's share is less than 10,000, there is no dispute.

dispute(LossID) :-
    not(no_dispute(LossID)),
    coverage_limit(LossID, 0). % It is mandatory that there is a dispute if the loss is not covered.

dispute(LossID) :-
    not(no_dispute(LossID)),
    acme_share(LossID, Amount),
    Amount > 1000000. % It is mandatory that there is a dispute if Acme's share greater than 1,000,000.

