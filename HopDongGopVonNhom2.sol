// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GroupFunding {
    address public owner;
    uint public totalContributed;
    bool public fundsDistributed;
    uint public deadline;

    mapping(address => uint) public contributions;
    address[] public contributors;

    event Contributed(address indexed contributor, uint amount);
    event Withdrawn(address indexed contributor, uint amount);
    event Distributed(uint totalAmount);

    constructor(uint _durationInMinutes) {
        owner = msg.sender;
        deadline = block.timestamp + (_durationInMinutes * 1 minutes);
        fundsDistributed = false;
    }

    modifier onlyBeforeDeadline() {
        require(block.timestamp < deadline, "Het thoi gian gop von");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Chi owner moi duoc thuc hien");
        _;
    }

    // Gửi tiền góp vốn
    function contribute() public payable onlyBeforeDeadline {
        require(msg.value > 0, "Phai gui mot so tien");
        require(!fundsDistributed, "Tien da duoc chia");

        if (contributions[msg.sender] == 0) {
            contributors.push(msg.sender);
        }

        contributions[msg.sender] += msg.value;
        totalContributed += msg.value;

        emit Contributed(msg.sender, msg.value);
    }

    // Fallback function nhận tiền trực tiếp
    receive() external payable onlyBeforeDeadline {
        require(msg.value > 0, "Khong the gui 0 ETH");
        require(!fundsDistributed, "Tien da duoc chia");

        if (contributions[msg.sender] == 0) {
            contributors.push(msg.sender);
        }

        contributions[msg.sender] += msg.value;
        totalContributed += msg.value;

        emit Contributed(msg.sender, msg.value);
    }

    // Chia lại tiền theo tỷ lệ góp
    function distributeFunds() external onlyOwner {
        require(!fundsDistributed, "Da chia tien roi");
        require(totalContributed > 0, "Khong co tien de chia");

        fundsDistributed = true;

        for (uint i = 0; i < contributors.length; i++) {
            address user = contributors[i];
            uint amount = (address(this).balance * contributions[user]) / totalContributed;
            payable(user).transfer(amount);
        }

        emit Distributed(address(this).balance);
    }

    // Cho phép người dùng rút lại tiền nếu chưa chia
    function withdraw() external {
        require(!fundsDistributed, "Da chia tien, khong the rut");
        uint amount = contributions[msg.sender];
        require(amount > 0, "Khong co tien de rut");

        contributions[msg.sender] = 0;
        totalContributed -= amount;

        payable(msg.sender).transfer(amount);
        emit Withdrawn(msg.sender, amount);
    }

    // Xem tỷ lệ góp
    function getContributionRatio(address user) external view returns (uint) {
        if (totalContributed == 0) return 0;
        return (contributions[user] * 10000) / totalContributed; // phần nghìn
    }

    // Xem danh sách người góp
    function getContributors() external view returns (address[] memory) {
        return contributors;
    }

    // Xem thời hạn góp vốn
    function getRemainingTime() external view returns (uint) {
        if (block.timestamp >= deadline) return 0;
        return deadline - block.timestamp;
    }
}
