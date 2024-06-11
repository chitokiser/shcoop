// SPDX-License-Identifier: MIT  
// ver1.2
pragma solidity >=0.7.0 <0.9.0;

interface Icya {
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool); 
}

interface Imutbank {
    function depoup(address _user, uint _depo) external;
    function depodown(address _user, uint _depo) external;
    function getprice() external view returns (uint256);
    function getlevel(address user) external view returns (uint);
    function g9(address user) external view returns (uint); // 각 depo현황
    function getagent(address user) external view returns (address);
    function getmento(address user) external view returns (address);
    function expup(address _user, uint _exp) external;
}

contract Shmarket { //shcoop
    Icya cya;
    Imutbank mutbank;
    address public admin; 
    address public taxbank;
    uint256 public mid; 
    uint256 public masterfee; // 마스터등록비용
    uint256 public tax; // 매출
    uint256 public ownerfee; // 오너수익 기본값 94
  
    mapping(address => uint8) public staff;
    mapping(uint256 => Meta) public metainfo; // id별 계좌정보
    mapping(address => My) public myinfo; // id별 계좌정보
    event MetaCreated(uint256 indexed mid, string name, address indexed owner);
    event MetaUpdated(uint256 indexed mid, string name, address indexed owner);
    event MetaPurchased(uint256 indexed mid, address indexed buyer, uint256 time);
    event MetaListedForSale(uint256 indexed mid, uint256 price);
    event MetaReset(uint256 indexed mid, uint256 price);
    event TaxTransferred(uint256 amount);
      
    constructor(address _cya, address _taxbank, address _mutbank) {
        cya = Icya(_cya);
        mutbank = Imutbank(_mutbank);
        admin = msg.sender;
        staff[msg.sender] = 5;
        taxbank = _taxbank;
        ownerfee = 90;
        masterfee = 100*1e18;
    }

    struct Meta {
       
        string name; // 물건이름
        string location; // 물건 위치 주소
        string detail; // 물건 정보 상세페이지
        string img; // 물건 사진
        uint256 time; // 사용가능 시간 최소단위 1시간
        uint256 start; // 시작시간
        uint256 price; // 1시간기준 가격
        uint8 trade; // 거래가능성 (3: 거래가능, 2: 준비중, 1: 사용중)
        address owner; // 소유자
        address user; // 사용자
        address master;
    }

     struct My{  //발행자 자격
    uint256 depo;  //최초보증금
    uint256 myid; //내가 발행할 수 있는 첫id 기준
    uint256[]mymeta;//내가 발행한 계좌
    string tel; //발행인 텔레그램 id
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Caller is not admin");
        _;
    }

    modifier onlyStaff(uint level) {
        require(staff[msg.sender] >= level, "Insufficient staff level");
        _;
    }

    function staffup(address _staff, uint8 _level) public onlyStaff(5) {   
        staff[_staff] = _level;
    } 

    function ownerfeeup(uint256 _newFee) public onlyStaff(5) {   
        ownerfee = _newFee;
    } 

    function taxbankup(address _taxbank) public onlyStaff(5) {   
        taxbank = _taxbank;
    } 

    
      function masterup(string memory _tel) public {  //발행인 업
        require(mutbank.getmento(msg.sender) != address(0),"no member"); 
        require(myinfo[msg.sender].depo == 0,"already a publisher"); 
        require(g2(msg.sender) >= masterfee,"no cya"); 
        cya.approve(msg.sender,masterfee); 
        uint256 allowance = cya.allowance(msg.sender, address(this));
        require(allowance >= masterfee, "Check the token allowance");
        cya.transferFrom(msg.sender, address(this),masterfee);  
        tax += masterfee;
        myinfo[msg.sender].depo = masterfee;
        mutbank.depoup(mutbank.getmento(msg.sender),masterfee*10/100);
        myinfo[msg.sender].myid = mid;
        myinfo[msg.sender].tel = _tel;
        mid +=100;
        
    }


    function charge(uint _pay) public {  
        uint pay = _pay*1e18;
        require(g2(msg.sender) >= pay,"no cya");  
        cya.approve(msg.sender, pay); 
        uint256 allowance = cya.allowance(msg.sender, address(this));
        require(allowance >= pay, "Check the token allowance");
        cya.transferFrom(msg.sender, address(this), pay);  
        mutbank.depoup(msg.sender,pay);
    }

    function newMeta(uint _mid,string memory _name, string memory _location, string memory _detail, string memory _img, uint256 _price, address _owner) public  {  
         uint mymid = myinfo[msg.sender].myid;
        require(myinfo[msg.sender].depo >= 1,"no master");
        require(metainfo[_mid].trade == 0 || metainfo[_mid].trade == 4,"Account that cannot be changed");
        require(mymid <= _mid && _mid < mymid + 100, "Out of setting range id");
        Meta storage meta = metainfo[mid];
        meta.name = _name;
        meta.location = _location;
        meta.detail = _detail;
        meta.img = _img;
        meta.price = _price;  //1시간기준
        meta.owner = _owner;
        meta.master = msg.sender;
        meta.trade = 3; // 거래 가능 상태
        myinfo[msg.sender].mymeta.push(_mid);
        

        emit MetaCreated(mid, _name, _owner);
    }

    function updateMeta(uint _mid, string memory _name, string memory _location, string memory _detail, string memory _img, uint256 _price, address _owner) public onlyStaff(5) {  
        Meta storage meta = metainfo[_mid];
        meta.name = _name;
        meta.location = _location;
        meta.detail = _detail;
        meta.img = _img;
        meta.price = _price*1e18;
        meta.owner = _owner;
        meta.trade = 3; // 거래 가능 상태

        emit MetaUpdated(_mid, _name, _owner);
    }

    function buyMeta(uint _mid, uint _time) public {  
        uint pay = (metainfo[_mid].price * _time) * 1e18;
        require(metainfo[_mid].trade == 3, "Not for sale");
        require(mutbank.getlevel(msg.sender) >= 1, "No membership level");
        require(mutbank.g9(msg.sender) >= pay, "Insufficient points");  
        mutbank.depodown(msg.sender, pay);
        mutbank.expup(msg.sender, pay / 1e16);
        metainfo[_mid].trade = 1; // 물건 사용 중
        mutbank.depoup(metainfo[_mid].owner, pay * ownerfee / 100);
        mutbank.depoup(metainfo[_mid].master, pay * 5 / 100);
        metainfo[_mid].user = msg.sender;
        tax += pay * (95 - ownerfee) / 100;

        emit MetaPurchased(_mid, msg.sender, _time);
    }

    function listMetaForSale(uint _mid, uint256 _price) public {  
        require(metainfo[_mid].user == msg.sender, "Not the user");
        require(metainfo[_mid].start + metainfo[_mid].time > block.timestamp + 3600, "Time left");
        metainfo[_mid].price = _price; // 가격 조정
        metainfo[_mid].trade = 3; // 거래 가능상태
        

        emit MetaListedForSale(_mid, _price);
    }

    function resetMeta(uint _mid, uint _price) public onlyStaff(3) {  
        require(metainfo[_mid].price > 1, "No items");
        Meta storage meta = metainfo[_mid];
        meta.price = _price; // 가격 리셋
        meta.trade = 3; // 거래 가능 상태로 리셋
        meta.user = address(0); // 사용자 초기화
        transferTax();
        emit MetaReset(_mid, _price);
    }

    function transferTax() public  {   
        uint pay = g1();
        cya.transfer(taxbank, pay);
        emit TaxTransferred(pay);
    } 

    function g1() public view virtual returns (uint256) {  
        return cya.balanceOf(address(this));
    }

    function g2(address user) public view virtual returns (uint256) {  
        return cya.balanceOf(user);
    }

    function g3(uint _mid, uint _time) public view virtual returns (uint256) { // 사용료 1시간당 산출
        return metainfo[_mid].price * _time;
    }

    function getMento(address user) external view returns (address) {
        return mutbank.getmento(user);
    }

    function getLevel(address user) external view returns (uint) {
        return mutbank.getlevel(user);
    }

    function getmymeta(address _user) external view returns (uint256[] memory) {
    return (
        myinfo[_user].mymeta
    );
}
}
