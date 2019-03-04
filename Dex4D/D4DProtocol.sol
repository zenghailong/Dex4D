pragma solidity ^0.4.24;


import "zeppelin-solidity/contracts/ownership/Claimable.sol";
import "zeppelin-solidity/contracts/lifecycle/Pausable.sol";
import "../contracts/interface/TokenDealerInterface.sol";
import "../contracts/interface/ReferralerInterface.sol";
import "../contracts/library/TokenDealerMapping.sol";
import "../contracts/library/StringUtils.sol";


contract D4DProtocol is Claimable, Pausable{
    TokenDealerMapping.itmap tokenDealerMap;

    uint256 public referralRequirement = 500e18;
    uint256 public arbitrageRequirement = 1000e18;

    string constant internal ethSymbol = "eth";

    uint8 constant public decimals = 18;
    string constant public name = "Dex4D Token";
    string constant public symbol = "D4D";

    ReferralerInterface internal Referralercontract = ReferralerInterface(0x498C8Ca5751Bf63339f00Febe34051f0C0611Bf1);

    constructor(address _referralerContract)
        public
    {
        Referralercontract = ReferralerInterface(_referralerContract);
    }

    function addDealer(string _symbol, address _dealerAddress) 
        public 
        onlyOwner()
        whenNotPaused()
        returns (uint size) 
    {
        require(TokenDealerMapping.contains(tokenDealerMap, _symbol) == false);
        TokenDealerMapping.insert(tokenDealerMap, _symbol, _dealerAddress);
        return tokenDealerMap.size;
    }

    function removeDealer(string _symbol) 
        public 
        onlyOwner()
        whenNotPaused()
        returns (uint size) 
    {
        require(TokenDealerMapping.contains(tokenDealerMap, _symbol) == true);
        TokenDealerMapping.remove(tokenDealerMap, _symbol);
        return tokenDealerMap.size;
    }

    function getDealer(string _symbol) 
        public 
        view 
        returns (address) 
    {
        return tokenDealerMap.data[_symbol].value;
    }

    function setReferralRequirement(uint256 _amountOfTokens) 
        public
        onlyOwner()
        whenNotPaused()
    {
        referralRequirement = _amountOfTokens;
    }

    function setArbitrageRequirement(uint256 _amountOfTokens) 
        public
        onlyOwner()
        whenNotPaused()
    {
        arbitrageRequirement = _amountOfTokens;
    }
    
    function balanceOf( address _customerAddress) 
        public  
        view
        returns (uint256 _sum) 
    {
        for (uint i = TokenDealerMapping.iterate_start(tokenDealerMap); 
             TokenDealerMapping.iterate_valid(tokenDealerMap, i); 
             i = TokenDealerMapping.iterate_next(tokenDealerMap, i))
        {
            address _value;
            (, _value) = TokenDealerMapping.iterate_get(tokenDealerMap, i);
            TokenDealerInterface _dealerContract = TokenDealerInterface(_value);
            _sum += _dealerContract.balanceOf(_customerAddress);
        } 
    }

    function balanceOfOneToken(string _symbol, address _customerAddress) 
        public 
        view 
        returns (uint256)
    {
        TokenDealerInterface _dealerContract = TokenDealerInterface(tokenDealerMap.data[_symbol].value);
        require(_dealerContract != address(0));
        return _dealerContract.balanceOf(_customerAddress);
    }

    //add all s3d
    function totalSupply() 
        public 
        view
        returns (uint256 _sum) 
    {
        _sum = 0;
        for (uint i = TokenDealerMapping.iterate_start(tokenDealerMap);
             TokenDealerMapping.iterate_valid(tokenDealerMap, i);
             i = TokenDealerMapping.iterate_next(tokenDealerMap, i))
        {
            address _value;
            (, _value) = TokenDealerMapping.iterate_get(tokenDealerMap, i);
            TokenDealerInterface _dealerContract = TokenDealerInterface(_value);
            _sum += _dealerContract.totalSupply();
        }
    }

    function totalSupplyOfOneToken(string _symbol) 
        public 
        view 
        returns (uint256) 
    {
        TokenDealerInterface _dealerContract = TokenDealerInterface(tokenDealerMap.data[_symbol].value);
        require(_dealerContract != address(0));
        return _dealerContract.totalSupply();
    }

    modifier arbitrageBarrier() 
    {
        require(balanceOf(msg.sender) >= arbitrageRequirement || Referralercontract.isArbitrager(msg.sender));
        _;
    }

    function buy(string _symbol, uint256 _tokenAmount, address _referredBy)
        public
        payable
        whenNotPaused()
        returns(uint256)
    {
        TokenDealerInterface _dealerContract = TokenDealerInterface(tokenDealerMap.data[_symbol].value);
        require(_dealerContract != address(0));

        address _referrer = _referredBy;
        if( 
            // no cheating!
            _referrer == msg.sender 
            
            // does the referrer have at least X whole tokens?
            // i.e is the referrer a godly chad masternode
            || ((balanceOf(_referrer) < referralRequirement)

            // not in referal referraler list
            && !Referralercontract.isReferraler(_referrer))
        ) {
            _referrer = 0x0000000000000000000000000000000000000000;
        }

        if(StringUtils.compare(_symbol, ethSymbol) == 0) {
            _dealerContract.buy.value(msg.value)(msg.sender, msg.value, _referrer);
        } else {
            _dealerContract.buy(msg.sender, _tokenAmount, _referrer);
        }
    }

    function distribute(string _symbol, uint256 _amountTokens)
        public
        payable
        whenNotPaused()
    {
        TokenDealerInterface _dealerContract = TokenDealerInterface(tokenDealerMap.data[_symbol].value);
        require(_dealerContract != address(0));

        if(StringUtils.compare(_symbol, ethSymbol) == 0) {
            _dealerContract.distribute.value(msg.value)(msg.sender, msg.value);
        } else {
            _dealerContract.distribute(msg.sender, _amountTokens);
        }
    }

    function reinvest(string _symbol, uint256 _buyAmount) 
        public
        whenNotPaused()
    {
        TokenDealerInterface _dealerContract = TokenDealerInterface(tokenDealerMap.data[_symbol].value);
        require(_dealerContract != address(0));
        _dealerContract.reinvest(msg.sender, _buyAmount);
    }

    function exit(string _symbol) 
        public
        whenNotPaused() 
    {
        TokenDealerInterface _dealerContract = TokenDealerInterface(tokenDealerMap.data[_symbol].value);
        require(_dealerContract != address(0));
        _dealerContract.exit(msg.sender);
    }

    function withdrawAll() 
        public 
        whenNotPaused()
    {
        bool _canWithdraw = false;

        for (uint i = TokenDealerMapping.iterate_start(tokenDealerMap); 
             TokenDealerMapping.iterate_valid(tokenDealerMap, i); 
             i = TokenDealerMapping.iterate_next(tokenDealerMap, i))
        {
            address _value;
            (, _value) = TokenDealerMapping.iterate_get(tokenDealerMap, i);
            TokenDealerInterface _dealerContract = TokenDealerInterface(_value);
            if (_dealerContract.referralBalanceOf(msg.sender) > 0 || _dealerContract.dividendsOf(msg.sender) > 0 || _dealerContract.selloutBalanceOf(msg.sender) > 0) {
                _canWithdraw = true;
                _dealerContract.withdrawAll(msg.sender);
            }
        }
        require(_canWithdraw == true, "no dividends to withdraw");
    }

    function withdraw(string _symbol, uint256 _withdrawAmount) 
        public
        whenNotPaused()
    {
        TokenDealerInterface _dealerContract = TokenDealerInterface(tokenDealerMap.data[_symbol].value);
        require(_dealerContract != address(0));
        _dealerContract.withdraw(msg.sender, _withdrawAmount);
    }

    function sell(string _symbol, uint256 _amountOfTokens) 
        public
        whenNotPaused()
    {
        TokenDealerInterface _dealerContract = TokenDealerInterface(tokenDealerMap.data[_symbol].value);
        require(_dealerContract != address(0));
        _dealerContract.sell(msg.sender, _amountOfTokens);
    }

    function totalBalance(string _symbol) 
        public 
        view 
        returns(uint256) 
    {
        TokenDealerInterface _dealerContract = TokenDealerInterface(tokenDealerMap.data[_symbol].value);
        require(_dealerContract != address(0));
        return _dealerContract.totalBalance();
    }


    function dividendsOf(string _symbol, address _customerAddress) 
        public
        view  
        returns(uint256) 
    {
        TokenDealerInterface _dealerContract = TokenDealerInterface(tokenDealerMap.data[_symbol].value);
        require(_dealerContract != address(0));
        return _dealerContract.dividendsOf(_customerAddress);
    }

    function referralBalanceOf(string _symbol, address _customerAddress) 
        public
        view  
        returns(uint256) 
    {
        TokenDealerInterface _dealerContract = TokenDealerInterface(tokenDealerMap.data[_symbol].value);
        require(_dealerContract != address(0));
        return _dealerContract.referralBalanceOf(_customerAddress);
    }

    function selloutBalanceOf(string _symbol, address _customerAddress)
        public 
        view
        returns(uint256)
    {
        TokenDealerInterface _dealerContract = TokenDealerInterface(tokenDealerMap.data[_symbol].value);
        require(_dealerContract != address(0));
        return _dealerContract.selloutBalanceOf(_customerAddress);
    }

    function sellPrice(string _symbol) 
        public 
        view 
        returns(uint256) 
    {
        TokenDealerInterface _dealerContract = TokenDealerInterface(tokenDealerMap.data[_symbol].value);
        require(_dealerContract != address(0));
        return _dealerContract.sellPrice();
    }

    function buyPrice(string _symbol) 
        public 
        view 
        returns(uint256) 
    {
        TokenDealerInterface _dealerContract = TokenDealerInterface(tokenDealerMap.data[_symbol].value);
        require(_dealerContract != address(0));
        return _dealerContract.buyPrice();
    }

    function withoutFeePrice(string _symbol)
        public
        view
        returns(uint256)
    {
        TokenDealerInterface _dealerContract = TokenDealerInterface(tokenDealerMap.data[_symbol].value);
        require(_dealerContract != address(0));
        return _dealerContract.withoutFeePrice();        
    }

    function calculateTokensReceived(string _symbol, uint256 _buyTokenToSpend) 
        public 
        view 
        returns(uint256) 
    {
        TokenDealerInterface _dealerContract = TokenDealerInterface(tokenDealerMap.data[_symbol].value);
        require(_dealerContract != address(0));
        return _dealerContract.calculateTokensReceived(_buyTokenToSpend);
    }

    function calculateBuyTokenSpend(string _symbol, uint256 _tokensToBuy) 
        public 
        view 
        returns(uint256) 
    {
        TokenDealerInterface _dealerContract = TokenDealerInterface(tokenDealerMap.data[_symbol].value);
        require(_dealerContract != address(0));
        return _dealerContract.calculateBuyTokenSpend(_tokensToBuy);
    }

    function calculateBuyTokenReceived(string _symbol, uint256 _tokensToSell) 
        public 
        view 
        returns(uint256) 
    {
        TokenDealerInterface _dealerContract = TokenDealerInterface(tokenDealerMap.data[_symbol].value);
        require(_dealerContract != address(0));
        return _dealerContract.calculateBuyTokenReceived(_tokensToSell);
    }

    function arbitrageTokens(string _fromSymbol, string _toSymbol, uint256 _amountOfTokens) 
        public
        arbitrageBarrier()
        whenNotPaused() 
    {
        TokenDealerInterface _escapeContract = TokenDealerInterface(tokenDealerMap.data[_fromSymbol].value);
        require(_escapeContract != address(0));

        _escapeContract.escapeTokens(msg.sender, _amountOfTokens); 

        TokenDealerInterface _dealerContract = TokenDealerInterface(tokenDealerMap.data[_toSymbol].value);
        require(_dealerContract != address(0));

        _dealerContract.arbitrageTokens(msg.sender, _amountOfTokens);
    }

}
