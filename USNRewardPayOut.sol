import "./RewardOffer.sol";


contract USNRewardPayOut {

     RewardOffer public usnContract;

     constructor(RewardOffer _usnContract) {
          usnContract = _usnContract;
     }

     // interface for USN
     function payOneTimeReward() public returns(bool) {
         if (msg.value < usnContract.getDeploymentReward())
             revert("insufficient deployment reward");

         if (usnContract.getOriginalClient().DAOrewardAccount().call.value(msg.value)()) {
             return true;
         } else {
             revert("payment reward error");
         }
     }

     // pay reward
     function payReward() public returns(bool) {
         if (usnContract.getOriginalClient().DAOrewardAccount().call.value(msg.value)()) {
             return true;
         } else {
             revert("uanble to pay reward");
         }
     }
}
