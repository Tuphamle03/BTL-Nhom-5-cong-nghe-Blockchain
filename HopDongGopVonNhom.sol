// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GroupFunding {
    address public owner;
    uint public totalContributed;
    bool public fundsDistributed;

    mapping(address => uint) public contributions;
    address[] public contributors;

    constructor() {
        owner = msg.sender;
        fundsDistributed = false;
    }

    // Gửi tiền góp vốn
    function contribute() public payable {
        require(msg.value > 0, "Phai gui mot so tien");
        require(!fundsDistributed, "Tien da duoc chia");

        if (contributions[msg.sender] == 0) {
            contributors.push(msg.sender);
        }

        contributions[msg.sender] += msg.value;
        totalContributed += msg.value;
    }

    // Fallback function nhận tiền trực tiếp
    receive() external payable {
        require(msg.value > 0, "Khong the gui 0 ETH");
        require(!fundsDistributed, "Tien da duoc chia");

        if (contributions[msg.sender] == 0) {
            contributors.push(msg.sender);
        }

        contributions[msg.sender] += msg.value;
        totalContributed += msg.value;
    }

    // Chia lại tiền theo tỷ lệ
    function distributeFunds() external {
        require(msg.sender == owner, "Chi owner moi duoc chia tien");
        require(!fundsDistributed, "Da chia tien roi");
        require(totalContributed > 0, "Khong co tien de chia");

        fundsDistributed = true;

        for (uint i = 0; i < contributors.length; i++) {
            address user = contributors[i];
            uint amount = (address(this).balance * contributions[user]) / totalContributed;
            payable(user).transfer(amount);
        }
    }

    // Xem tỷ lệ góp
    function getContributionRatio(address user) external view returns (uint) {
        if (totalContributed == 0) return 0;
        return (contributions[user] * 10000) / totalContributed; // phần nghìn
    }

    function getContributors() external view returns (address[] memory) {
        return contributors;
    }
}
