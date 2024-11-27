import "../base/ERC5192.sol";

contract SoulboundMembership is ERC5192 {
    enum MembershipTier { BRONZE, SILVER, GOLD }
    
    struct MembershipDetails {
        MembershipTier tier;
        uint256 issuedAt;
        uint256 validUntil;
    }
    
    mapping(uint256 => MembershipDetails) private _memberships;
    address public admin;
    uint256 private _nextMembershipId;

    constructor() ERC5192("SoulboundMembership", "MEMBER") {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    function issueMembership(
        address member,
        MembershipTier tier,
        uint256 validityPeriod
    ) external onlyAdmin returns (uint256) {
        uint256 membershipId = _nextMembershipId++;
        
        _mint(member, membershipId);
        _lock(membershipId);
        
        _memberships[membershipId] = MembershipDetails({
            tier: tier,
            issuedAt: block.timestamp,
            validUntil: block.timestamp + validityPeriod
        });

        return membershipId;
    }

    function isMembershipValid(uint256 tokenId) public view returns (bool) {
        require(_exists(tokenId), "Membership does not exist");
        return block.timestamp <= _memberships[tokenId].validUntil;
    }

    function getMembershipDetails(uint256 tokenId) 
        external 
        view 
        returns (
            MembershipTier tier,
            uint256 issuedAt,
            uint256 validUntil,
            bool isValid
        ) 
    {
        require(_exists(tokenId), "Membership does not exist");
        MembershipDetails memory details = _memberships[tokenId];
        return (
            details.tier,
            details.issuedAt,
            details.validUntil,
            isMembershipValid(tokenId)
        );
    }

    function renewMembership(uint256 tokenId, uint256 extension) 
        external 
        onlyAdmin 
    {
        require(_exists(tokenId), "Membership does not exist");
        _memberships[tokenId].validUntil += extension;
    }
}