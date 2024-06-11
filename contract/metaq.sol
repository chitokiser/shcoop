// SPDX-License-Identifier: MIT  
// ver1.2
pragma solidity >=0.7.0 <0.9.0;

interface Imut {      
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function g1() external view returns(uint256);
    function getdepot(address user) external view returns(uint256);
}

interface Imutbank {      // 멋뱅크
    function depoup(address _user, uint _depo) external;
    function depodown(address _user, uint _depo) external;
    function getprice() external view returns (uint256);
    function getlevel(address user) external view returns (uint);
    function g9(address user) external view returns (uint);  // 각 depo현황
    function getagent(address user) external view returns (address);
    function getmento(address user) external view returns (address);
    function expup(address _user, uint _exp) external;
}

contract Metaq {  // 멧큐   mut을 담보로 하여 이자율이 변동되는 디파이
    Imut mut;
    Imutbank mutbank;
    address public taxbank;
    address public admin;
    uint256 public tax; // 계약잔고
    mapping(address => bond) public mybond; // 나의 채권
    mapping(address => loan) public myloan; // 나의 대출
    mapping (address => uint) public staff;

  
    constructor(address _mut, address _mutb) { 
        mut = Imut(_mut);
        mutbank = Imutbank(_mutb);
        taxbank = _mutb;
        admin = msg.sender;
        tax = 1e20;
    }
    
    struct loan {
        uint256 depo;   // 갚을돈
        uint256 depo2;  // 대출 실행된 돈
        uint256 depot;  // 대출시간
        uint256 mutdepo;  // 담보 개수
    }

    struct bond {
        uint256 depo;   // 채권금액
        uint256 depot;  // 제공시간
    }

  function bonding(uint _pay) public {  // 유동성 제공
    uint pay = _pay * 1e18;
    require(mutbank.g9(msg.sender) >= pay, "not enough point");  
    require(mybond[msg.sender].depo == 0, "already have a bond"); 
    require(g6(msg.sender) != address(0), "no member"); 
    mutbank.depodown(msg.sender, pay);
    mutbank.depoup(g6(msg.sender), pay * 5 / 100);
    uint fee = pay * 5 / 100;  //멘토수당
    tax += pay - fee;
    uint mypay = pay * g11() /100;
    mybond[msg.sender].depo = mypay;
    mybond[msg.sender].depot = block.timestamp;
}


    function withdraw() public {  // 유동성 제공한 금액 인출
        uint pay = mybond[msg.sender].depo;
        require(pay >= 1, "no have a bond"); 
        require(mybond[msg.sender].depot + 90 days <= block.timestamp , "not time yet"); 
        mybond[msg.sender].depo = 0;
        mutbank.depoup(msg.sender, pay);
        mybond[msg.sender].depot = 0;
        tax -= pay;
    }

  function loaning(uint num) public {  // 대출
    uint pay = num * g7(); // mut 시세만큼 담보
    require(tax >= pay, "not enough point"); 
    require(g8(msg.sender) >= num, "not enough mut");  
    require(myloan[msg.sender].depo == 0, "already have a loan"); 
     require(g6(msg.sender) != address(0), "no member"); 

    mut.approve(msg.sender, num);
    uint256 allowance = mut.allowance(msg.sender, address(this));
    require(allowance >= num, "Check the allowance");
    mut.transferFrom(msg.sender, address(this), num); 

    uint mypay = (pay * 100) / g13();  // 대출 실행 금액  
    mutbank.depoup(msg.sender, mypay);  
    mutbank.depoup(g6(msg.sender), mypay * 5 / 100);

    uint fee = mypay * 5 / 100;
    tax -= mypay + fee;
    myloan[msg.sender].depo = pay;  // 갚을 돈
    myloan[msg.sender].depo2 = mypay;  // 실행금액
    myloan[msg.sender].depot = block.timestamp;
    myloan[msg.sender].mutdepo = num;  // 담보
 
}

function payback() public {  // 대출 상환
    uint pay = myloan[msg.sender].depo;
    uint mutpay = myloan[msg.sender].mutdepo;
    require(pay >= 1, "no have a loan"); 
    require(myloan[msg.sender].depot + 90 days >= block.timestamp , "not time yet"); 
    require(mutbank.g9(msg.sender) >= pay, "not enough point");  

    
    mutbank.depodown(msg.sender, pay); // 대출 상환
    tax += pay; // 수익으로 반영
    myloan[msg.sender].depo = 0; // 대출 정보 초기화
    myloan[msg.sender].depo2 = 0; // 대출 정보 초기화
    myloan[msg.sender].depot = 0; // 대출 정보 초기화
    
    myloan[msg.sender].mutdepo = 0; // 대출 정보 초기화
    mut.transfer(msg.sender, mutpay); // mut 지급
}

 

    function muttransfer(uint _num) public {  
        require(staff[msg.sender] >= 5, "no staff");
        mut.transfer(taxbank, _num);
    }   

    function staffup(address _staff, uint8 num) public {  
        require(admin == msg.sender, "no admin"); 
        staff[_staff] = num;
    }   
  
    function g3() public view returns(uint) { 
        return mut.balanceOf(address(this)) + 100;
    }  

    function g4() public view returns(uint) { // 계약이 가지고 있는 mut 시가총액
        return g3() * g7();
    }

    function g5(address user) public view returns(uint) { // 나의 mut 시가총액
        return g8(user) * g7();
    }

    function g6(address user) public view returns (address)
{  //멘토 가져오기
        return mutbank.getmento(user);
    }

    function g7() public view returns(uint) { // mut 시세
        return mutbank.getprice();
    }

    function g8(address user) public view returns(uint) { // mut 보유 현황
        return mut.balanceOf(user);
    }
  
    function g9(address user) public view returns(uint) { // 포인트 보유 현황
        return mutbank.g9(user);
    }

      function g10(address user) public view returns(uint) { // 개인 대출가능금액
        return g5(user)*100/g11();
    }

   
 function g11() public view returns(uint) { // 유동성제공 이자 비율
        return  100+ (g4() / tax);
    }

 

function g12(address user) public view returns(uint) { // 대출이자 보조지표
        return  mutbank.getlevel(user);
    }


    
     function g13() public view returns(uint) { // 대출이자 보조지표
        return  120+ (g4() / tax);
    }
}
