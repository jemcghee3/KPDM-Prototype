loss(01).
loss(02).
loss(03).
loss(04).
loss(05).
loss(06).
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
% should not be in dispute because cause is unknown and the claim is 500,000 net of deductible and Acme's share is 7%, or 35,000. Charlene is an engineer and can determine the cause of the loss
% unknown cause would lead to dispute if amount is greater than 100,000 for Acme's share.

cause_of_loss(06, unknown).
repair_plan(06, none).
estimate_pd_claim(06, 5000000).
estimate_bi_claim(06, 3000000).
estimate_ee_claim(06, 0).
business_interruption_duration(06, 1).
covers_loss(10101, 06).
examines_claim(sergio, 06).
examines_claim(charlene, 06).
% should be in dispute because cause is unknown and the claim is 4,500,000 net of deductible and Acme's share is 7%, or 315,000. Charlene is an engineer and can determine the cause of the loss

% policy related facts
applicable_policy(10101, 101). % policy 10101 is applicable to slip 101

policy_type(10101, iar). % policy 10101 is an industrial all risk policy
pd_deductible(10101, 500000). % policy 10101 has a property damage deductible of 500,000
bi_deductible(10101, 30). % policy 10101 has a business interruption deductible of 30 days
pd_bi_limit(10101, 250000000). % policy 10101 has a property damage and business interruption limit of 250,000,000
ee_limit(10101, 25000000). % policy 10101 has an extra expense limit of 25,000,000
sublimit(10101, war, 0). % policy 10101 has a sublimit for war of 0 (that is, a loss is not covered if it is caused by war)
% sublimit(PolicyID, unknown, 0). % until the cause is not known, the sublimit is zero.
% the above is not true. If the cause is not known, it needs to be investigated. A claim may be paid even if the cause cannot be determined because Acme must prove the cause is NOT covered.


% slip related facts
% slip_sublimit(101, bi, 2000000). % slip 101 has a sublimit for business interruption of 2,000,000 (per month)
slip_sublimit(101, earthquake, 5000000). % slip 101 has a sublimit of 5,000,000 if the cause of the loss is earthquake
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
% This is represented as a fact of the form covers_loss(PolicyID, LossID).

% Rule 2: It is necessary that a Policy insure one or more Insured.
% This Rule is not formalized because it is not necessary. We did not consider the case where a policy does not insure an insured.

% Rule 3: It is possible that a Policy is an aggregate one or more Slips.
% This is represented as a fact of the form applicable_policy(PolicyID, SlipID).

% Rule 4: It is necessary that Slip is written by one Insurer.
% This Rule is not formalized because it is not necessary. We considered the slip, the contract document, to be providing the insurance, not the insurer.

% Rule 5: It is necessary that an Insurer writes a Slip.
% This Rule is not formalized because it is not necessary. We considered the slip, the contract document, to be providing the insurance, not the insurer.

% Rule 6: It is possible for a Slip to contain one or more different sublimits from the policy.
% This is represented as a fact of the slip.

% Rule 11: It is necessary for a Policy to provide one or more Coverages.
provides_coverage(PolicyID, pd). % always true
% Other coverages can be provider for by the policy.
provides_coverage(PolicyID, ee) :- ee_limit(PolicyID, EELimit).
provides_coverage(PolicyID, bi) :- ee_limit(PolicyID, EELimit). % if coverage for EE, coverage for BI

% Rule 12: It is obligatory that a Coverage be limited by one or more Limits.
% This is represented as a fact of the policy.
% pd_bi_limit/2, ee_limit/2, sublimit/3

% Rule 13: It is necessary for a Coverage to pay after one or more Deductibles.
claim_after_deductible(LossID, Net_Claim, pd) :-
    deductible_satisfied(LossID, pd), % check if deductible is satisfied. Necessary to avoid errors when calculating the net claim
    covers_loss(PolicyID, LossID), % find the relevant policy
    provides_coverage(PolicyID, pd), % check for coverage
    estimate_pd_claim(LossID, EstimatedPDClaim), % find the estimated claim
    pd_deductible(PolicyId, PDDeductible), % find the deductible
    Net_Claim is EstimatedPDClaim - PDDeductible. % calculate the net claim

claim_after_deductible(LossID, 0, pd) :-
    not(deductible_satisfied(LossID, pd)). % check if deductible is satisfied
    % Return 0 if the deductible is not satisfied

claim_after_deductible(LossID, Net_Claim, bi) :- % for cases where there is no bi sublimit
    deductible_satisfied(LossID, bi), % check if deductible is satisfied. Necessary to avoid errors when calculating the net claim
    covers_loss(PolicyID, LossID), % find the relevant policy
    provides_coverage(PolicyID, bi), % check for coverage
    estimate_bi_claim(LossID, EstimatedBIClaim), % find the estimated claim, which will be expressed on a monthly basis
    bi_deductible(PolicyID, BI_Waiting_Period), % find the deductible
    business_interruption_duration(LossID, NumberOfMonths), % find the number of months of business interruption
    not(slip_sublimit(SlipID, bi, BI_Sublimit)), % when there is no sublimit
    Net_Claim is (NumberOfMonths - (BI_Waiting_Period / 30)) * EstimatedBIClaim. % calculate the net claim
    
claim_after_deductible(LossID, 0, bi) :-
    not(deductible_satisfied(LossID, bi)). % check if deductible is satisfied
    % Return 0 if the deductible is not satisfied

claim_after_deductible(LossID, Net_Claim, ee) :- 
    covers_loss(PolicyID, LossID), % find the relevant policy
    provides_coverage(PolicyID, ee), % check for coverage
    estimate_ee_claim(LossID, Net_Claim). % find the estimated claim. No deductible is applied.

% Rule 14: It is possible for a Policy to exclude one or more Exclusions.
% Exclusions are formalized as sublimits of zero.

% Rule 15: It is possible for two Exclusions of the same Slip to be different from each other.
% See Rule 14 and Rule 17.

% Rule 16: It is possible for two Deductibles of the same Slip to vary from each other.
% This is expressed as a fact of the policy.

% Rule 17: It is possible for two Limits of the same Slip to be distinct from each other.
% A slip may have a slip_sublimit, expressed as a fact of the slip.

% Rule 17.1: It is necessary for a Slip to have the sublimit of the Policy if the Slip does not have a sublimit and the Policy does.
slip_sublimit(SlipID, Cause, Amount) :- 
    applicable_policy(PolicyID, SlipID), 
    sublimit(PolicyID, Cause, Amount).
% The slip follows the policy where there are no differences.

% Rule 18: It is possible for a Policy to be of type CAR.
% This is represented as a fact of the policy.

% Rule 19: It is possible for a Policy to be of type IAR.
% This is represented as a fact of the policy.

% Rule 20: It is forbidden for a Policy to appear of type CAR and IAR at the same time.
policy_type(PolicyID, iar) :- \+ policy_type(PolicyID, car).
policy_type(PolicyID, car) :- \+ policy_type(PolicyID, iar).
% This distinction is ultimately not used. It would be relevant for an extension of the system to include a distinction between CAR and IAR policies.
% This defaults to IAR if neither is specified.

% Rule 21: It is necessary for a Slip to provide Coverage for Property Damage (PD).
provides_coverage(SlipID, pd). % always true

% Rule 22: It is possible for a Slip to provide Coverage for Business Interruption (BI).
provides_coverage(SlipID, bi) :- applicable_policy(PolicyID, SlipID), provides_coverage(PolicyID, bi).

% Rule 23: It is possible for a Slip to provide Coverage for Extra Expenses (EE).
provides_coverage(SlipID, ee) :- applicable_policy(PolicyID, SlipID), provides_coverage(PolicyID, ee).

% Rule 24: If and only if a Policy provides Coverage for BI, it is obligatory that the Policy provides Coverage for EE.
provides_coverage(PolicyID, ee) :- provides_coverage(PolicyID, bi). % if coverage for BI, coverage for EE
provided_coverage(PolicyID, bi) :- provides_coverage(PolicyID, ee). % if coverage for EE, coverage for BI

% Rule 25: It is permitted for a Policy to be of any type to give Coverage for BI.
% This is represented as a fact of the policy.

% Rule 26: It is necessary for each Slip to share a Share of the Policy.
% Since we are only concerned with Acme, we represent their share as a fact pulled from Acme's records.

% The following rule calculates the share of the claim that Acme must pay.
acme_share(LossID, Share_Amount) :-
    covers_loss(PolicyID, LossID),
    applicable_policy(PolicyID, SlipID),
    acme_insures_share(SlipID, Share),
    !, % This cut is needed to avoid an infinite loop
    total_net_claim(LossID, Total_Amount),
    Share_Amount = Share * Total_Amount.

% Rule 27: It is obligatory for the Deductible to be either a PD-Deductible or a BI-Deductible.
% This is represented as a fact of the policy.

% Rule 28: It is obligatory for the BI-Deductible to be formatted an integer.
% This is represented as a fact of the deductible as part of the policy.

% Rule 29: It is obligatory for BI-Deductible to be expressed in number of days.
% This is represented as a fact of the deductible as part of the policy.

% Rule 34: It is obligatory for an Insured to pay a Deductible before the Insurer pays the Claim.
deductible_satisfied(LossID, pd) :- covers_loss(PolicyID, LossID), % find the relevant policy
    estimate_pd_claim(LossID, Amount), % find the estimated claim
    pd_deductible(PolicyID, Deductible), % find the deductible
    Amount > Deductible. % check if the claim is higher than the deductible

deductible_satisfied(LossID, bi) :- covers_loss(PolicyID, LossID), % find the relevant policy
    business_interruption_duration(LossID, NumberOfMonths), % find the number of months of business interruption
    bi_deductible(PolicyID, BI_Waiting_Period), % find the deductible
    NumberOfMonths > BI_Waiting_Period / 30. % check if the number of months is higher than the deductible

% Rule 39: It is obligatory for the Insurer to provide Coverage for a Claim if and only if the Deductible is Satisfied.
% See Rule 13.

% Rule 43: It is possible for a Claim to be covered by Coverage of one or more Policies.
% coverage_claim(ClaimId, PolicyId) :- claim(ClaimId), policy(PolicyId).
% Rule 1.1 already covers this use case.

% Rule 44: It is necessary for a Loss to present as an event.
% This is represented as a fact of the loss, which has a cause and effects.

% Rule 45: It is obligatory for a Claim to be examined by one or more Experts.
% Rule 46: It is obligatory that an Expert examines the Claim.
% This is represented as a fact of the loss.

% Rule 47: It is permitted for the Coverage to be limited by a Limit due to the Cause of Loss.
coverage_limit(LossID, Limit) :- 
    covers_loss(PolicyID, LossID), % find the relevant policy
    applicable_policy(PolicyID, SlipID), % find the relevant slip
    pd_bi_limit(PolicyID, Amount), % find the limit of the policy
    cause_of_loss(LossID, Cause), % find the cause of the loss
    slip_sublimit(SlipID, Cause, Sub), % find the sublimit of the slip
    nonvar(Sub), % check to see if the sublimit has been found
    !, % to avoid backtracking when there is a sublimit
    min(Amount, Sub, Limit). % return the lower of the two limits

coverage_limit(LossID, Amount) :- covers_loss(PolicyID, LossID),
    pd_bi_limit(PolicyID, PD_BI_Limit),
    ee_limit(PolicyID, EE_Limit),
    Amount = PD_BI_Limit + EE_Limit.
% This is the default case, where there is no sublimit.

total_net_claim(LossID, Amount) :-
    coverage_limit(LossID, Sublimit),
    claim_after_deductible(LossID, PD_Net_Claim, pd),
    claim_after_deductible(LossID, BI_Net_Claim, bi),
    claim_after_deductible(LossID, EE_Net_Claim, ee),
    pd_bi_limit(PolicyID, PD_BI_Limit),
    ee_limit(PolicyID, EE_Limit),
    Sum = min(PD_BI_Limit, (PD_Net_Claim + BI_Net_Claim)) + min(EE_Limit, EE_Net_Claim),
    min(Sum, Sublimit, Amount).

min(A, B, A) :- A < B.
min(A, B, B) :- A >= B.


% Rule 48: It is permitted for the Slip to provide no Coverage for a Claim due to the Cause of Loss.  
% Rule 47 already covers this use case, as the slip_sublimit/3 could have a value of 0.


% Final Rules to Determine Dispute
no_dispute(LossID) :- 
    acme_share(LossID, Amount), 
    Amount < 10000,
    Amount > 0.
    % If Acme's share is less than 10,000 (but the claim is not excluded), there is no dispute, even if other triggers exist.

dispute(LossID) :-
    not(no_dispute(LossID)),
    coverage_limit(LossID, 0). % It is mandatory that there is a dispute if the loss is not covered.

dispute(LossID) :-
    not(no_dispute(LossID)),
    acme_share(LossID, Amount),
    Amount > 1000000. % It is mandatory that there is a dispute if Acme's share greater than 1,000,000.

dispute(LossID) :-
    not(no_dispute(LossID)),
    cause_of_loss(LossID, unknown),
    acme_share(LossID, Amount),
    Amount >= 100000. % It is mandatory that there is a dispute if Acme's share greater than 100,000 and the cause is unknown.