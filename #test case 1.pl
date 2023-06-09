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
other_policies_covering_loss(01, true). % this is not used, but would be a relevant fact for an extension of the program
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

% slip related facts
% slip_sublimit(101, bi, 2000000). % slip 101 has a sublimit for business interruption of 2,000,000 (per month)
slip_sublimit(101, earthquake, 5000000). % slip 101 has a sublimit of 5,000,000 if the cause of the loss is earthquake
acme_insures_share(101, 0.07). % Acme insures 7% of the risk under slip 101

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

% Rule 1.1: It is necessary for a Loss to covered by a Policy.
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

% Rule 10: It is necessary for a Policy to provide one or more Coverages.
provides_coverage(PolicyID, pd). % always true
% Other coverages can be provided for by the policy.
provides_coverage(PolicyID, ee) :- ee_limit(PolicyID, EELimit).
provides_coverage(PolicyID, bi) :- ee_limit(PolicyID, EELimit). % if coverage for EE, coverage for BI

% Rule 11: It is obligatory that a Coverage be limited by one or more Limits.
% This is represented as a fact of the policy.
% pd_bi_limit/2, ee_limit/2, sublimit/3

% Rule 12: It is necessary for a Coverage to pay after one or more Deductibles.
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

% Rule 13: It is possible for a Policy to exclude one or more Exclusions.
% Exclusions are formalized as sublimits of zero.

% Rule 14: It is possible for two Exclusions of the same Slip to be different from each other.
% See Rule 14 and Rule 17.

% Rule 15: It is possible for two Deductibles of the same Slip to vary from each other.
% This is expressed as a fact of the policy.

% Rule 16: It is possible for two Limits of the same Slip to be distinct from each other.
% A slip may have a slip_sublimit, expressed as a fact of the slip.

% Rule 16.1: It is necessary for a Slip to have the sublimit of the Policy if the Slip does not have a Limit and the Policy does.
slip_sublimit(SlipID, Cause, Amount) :- 
    applicable_policy(PolicyID, SlipID), 
    sublimit(PolicyID, Cause, Amount).
% The slip follows the policy where there are no differences.

% Rule 17: It is possible for a Policy to be of type CAR.
% This is represented as a fact of the policy.

% Rule 18: It is possible for a Policy to be of type IAR.
% This is represented as a fact of the policy.

% Rule 19: It is forbidden for a Policy to appear of type CAR and IAR at the same time.
policy_type(PolicyID, iar) :- \+ policy_type(PolicyID, car).
policy_type(PolicyID, car) :- \+ policy_type(PolicyID, iar).
% This distinction is ultimately not used. It would be relevant for an extension of the system to include a distinction between CAR and IAR policies.
% This defaults to IAR if neither is specified.

% Rule 20: It is necessary for a Slip to provide Coverage for Property Damage (PD).
provides_coverage(SlipID, pd). % always true

% Rule 21: It is possible for a Slip to provide Coverage for Business Interruption (BI).
provides_coverage(SlipID, bi) :- applicable_policy(PolicyID, SlipID), provides_coverage(PolicyID, bi).

% Rule 22: It is possible for a Slip to provide Coverage for Extra Expenses (EE).
provides_coverage(SlipID, ee) :- applicable_policy(PolicyID, SlipID), provides_coverage(PolicyID, ee).

% Rule 23: If and only if a Policy provides Coverage for BI, it is obligatory that the Policy provides Coverage for EE.
provides_coverage(PolicyID, ee) :- provides_coverage(PolicyID, bi). % if coverage for BI, coverage for EE
provided_coverage(PolicyID, bi) :- provides_coverage(PolicyID, ee). % if coverage for EE, coverage for BI

% Rule 24: It is permitted for a Policy to be of any type to give Coverage for BI.
% This is represented as a fact of the policy, which Prolog recognizes if there is an EE limit.

% Rule 25: It is necessary for each Slip to share a Share of the Policy.
% Since we are only concerned with Acme, we represent their share as a fact pulled from Acme's records.

% Rule 26: It is obligatory for Acme to pay its Share of the Loss.
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

% Rule 30: It is possible for the BI-Deductible to be first 15 days of the Loss. 
% Rule 31: It is possible for the BI-Deductible to be first 30 days of the Loss. 
% Rule 32: It is possible for the BI-Deductible to be 15 times the average daily Loss.
% These rules were removed as they would be expressed as facts of the policy. 
% Rule 32 could have been implimented as a rule, but it was not necessary for the scope of this project.

% Rule 33: It is obligatory for an Insured to pay a Deductible before the Insurer pays the Claim.
deductible_satisfied(LossID, pd) :- covers_loss(PolicyID, LossID), % find the relevant policy
    estimate_pd_claim(LossID, Amount), % find the estimated claim
    pd_deductible(PolicyID, Deductible), % find the deductible
    Amount > Deductible. % check if the claim is higher than the deductible

deductible_satisfied(LossID, bi) :- covers_loss(PolicyID, LossID), % find the relevant policy
    business_interruption_duration(LossID, NumberOfMonths), % find the number of months of business interruption
    bi_deductible(PolicyID, BI_Waiting_Period), % find the deductible
    NumberOfMonths > BI_Waiting_Period / 30. % check if the number of months is higher than the deductible

% Rule 34: It is permitted for a Deductible to be a Per-Claim Deductible. 
% Rule 35: It is forbidden for the Insurer to grant Coverage for any Claim lower than the Per-Claim Deductible. 
% Rule 36: It is obligatory for the Insurer to offer Coverage for any Claim higher than the Per-Claim Deductible. 
% Rule 37: It is permitted for a Deductible to happen to be an Aggregate Deductible. 
% These rules relate to the difference between aggregate deductible and per-claim deductible.
% They were not implimented here as it would be the implementation of a mathematical calculation.
% During the first coaching, we were advised to focus on the business rules and not the calculations.
% The knowledge base could be expanded to include the calculation, but it was not necessary for the scope of this project.

% Rule 38: It is obligatory for the Insurer to provide Coverage for a Claim if and only if the Deductible is Satisfied.
% See Rule 13.

% RUle 39: A Per-Claim Deductible is Satisfied if the Claim is for a higher amount than the Per-Claim Deductible.  
% Rule 40: An Aggregate Deductible is Satisfied if the sum of the amounts of all Claims on the Policy is for a higher amount than the Aggregate Deductible.  
% Rule 41: A Deductible is Satisfied if and only if the Per-Claim Deductible and the Aggregate Deductible are Satisfied.  
% These rules relate to the difference between aggregate deductible and per-claim deductible.
% As mentioned above, they were not implimented here as it would be the implementation of a mathematical calculation.

% Rule 42: It is necessary for an Insured to file one or more Claims. 
% This is represented as a fact of the loss. Unfiled claims are not represented in the knowledge base.

% Rule 43: It is possible for a Claim to be covered by Coverage of one or more Policies.
% Rule 1.1 already covers this use case.
% Of interest in an extension of this knowledge base would be to add a rule that checks if the claim is covered by more than one policy.
% To do this would require to create knowledge of policies other than those to which Acme is a party.
% In cases where different insurance policies cover the same loss, the insurance companies for each policy may dispute how the coverage is split.

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

% Rule 49: It is permitted for the Insurer to employ one or more Experts. 
% Rule 50: It is permitted for the Insurer to hire an Expert employed by one or more other Insurers. 
% Rule 51: It is possible for the Expert to be an Adjuster, an Accountant, an Engineer, or Coverage Counsel. 
% Rules related to experts are represented as facts of the loss.

% 52: It is possible for a Claim to be Technically Complex.
% This could be considered for an extension of the knowledge base.

% 53: It is necessary that a CAR Policy is less likely to be Technically Complex than an IAR Policy.
% This would be its own knowledge intensive process, and is not represented in the knowledge base.

% Rule 54: It is obligatory that a Claim is Technically Complex if the Insured will not repair or replace the Loss.
% Rule 55: It is obligatory that the claim is Technically Complex if the Cause of the Loss is Unknown.
% Rule 56: It is possible for an EE Claim to be Uncertain.
% Rule 57: It is possible for a BI Claim to be Uncertain.
% Rule 58: It is possible for the EE Claim to be Uncertain if the BI Claim is Uncertain. 
% Rule 59: It is necessary that the Location of a Loss affects whether a Claim is Uncertain.
% Rule 60: It is obligatory that the Claim is Uncertain if the Location is Political.
% Rule 61: It is obligatory for the EE Claim to last for the duration of the BI Claim if the Claim is Consequential. 
% These rules could be considered for an extension of the knowledge base.

% Rule 62: It is obligatory for an Adjuster to examine a PD Claim.
% Rule 63: It is obligatory for an Accountant to inspect a Claim if the Claim is Uncertain.
% Rule 64: It is obligatory for an Engineer to review the Cause of the Loss if the Cause of the Loss is Unknown.
% Rule 65: It is obligatory for an Engineer to verify a PD Claim if it is Technically Complex.
% Rule 66: It is obligatory for Coverage Counsel to investigate the Coverage if there is more than one Policy.
% Rule 67: It is obligatory for Coverage Counsel to assess the Coverage if Cause is subject to one or more Limits or Exclusions.
% Rules 62-67 were not formalized because the decision to hire an expert would be the output of another knowledge intensive process.

% Rule 68: It is possible for a Dispute to exist if a Claim is Technically Complex. 
% Rule 69: It is obligatory for a Dispute to exist if a Claim is Uncertain.
% These rules could be considered for an extension of the knowledge base.

% Rule 70: It is possible for a Dispute to exist if Coverage Counsel is employed. 
% Rule 70 is not formalized because the decision to hire an expert would be the output of another knowledge intensive process. 
% Rule 71: It is obligatory for a Dispute to exist if Insurers in the same Market employ two of the same type of Expert for a Claim
% Rule 71 is not formalized because it would require knowledge of policies other than those to which Acme is a party.



% Rule 72: It is obligatory for a Dispute to exist if two Policies provide Coverage for the same Loss.
% Rule 73: It is possible for a Dispute to exist if the Claim is greater than the Limit for the Coverage of Acme’s Slip but less than the Limit of the Policy.
% These rules could be considered for an extension of the knowledge base.


% Rule 74: It is possible for a Dispute to exist if the Claim is less than the Deductible for the Coverage of Acme’s Slip but greater than the Deductible of the Policy.
% Slips can have deductibles different from the policy. This was not formalized but could be an extension of the knowledge base.


% Final Rules to Determine Dispute

% Rule 75: It is obligatory for a Dispute to exist if the Cause of the Loss is Excluded.
dispute(LossID) :-
    not(no_dispute(LossID)),
    coverage_limit(LossID, 0). % It is mandatory that there is a dispute if the loss is not covered.

% Rule 76: It is obligatory for a Dispute to exist if Acme’s Share of the Claim is for greater than 1,000,000 CHF
dispute(LossID) :-
    not(no_dispute(LossID)),
    acme_share(LossID, Amount),
    Amount > 1000000. % It is mandatory that there is a dispute if Acme's share greater than 1,000,000.

% Rule 77 It is possible for a Dispute to exist if Acme’s Share of the Claim is for greater than 100,000 CHF.
dispute(LossID) :-
    not(no_dispute(LossID)),
    cause_of_loss(LossID, unknown),
    acme_share(LossID, Amount),
    Amount >= 100000. % It is mandatory that there is a dispute if Acme's share greater than 100,000 and the cause is unknown.

% Rule 78: It is forbidden for a Dispute to exist if Acme’s Share of the Claim is less than 10,000 CHF
no_dispute(LossID) :- 
    acme_share(LossID, Amount), 
    Amount < 10000,
    Amount > 0.
    % If Acme's share is less than 10,000 (but the claim is not excluded), there is no dispute, even if other triggers exist.