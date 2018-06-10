pragma solidity ^0.4.16;

contract BlockTracking {
    // state variables
    address shipper;
    enum OrderStatus { labelCreated, outForDelivery, delivered, notDelivered }

    // tracking data structure and mapping
    struct Tracking {
        address provider;
        address recipient;
        string time;
        string notes;
        OrderStatus orderStatus;
    }
    mapping (uint256 => Tracking) public trackers;
    
    // event logs for order creation and updates
    event OrderUpdate(uint256 trackingNo, address _from, address _to, OrderStatus _currentStatus, string notes, string _time);
    
    constructor() public {
        shipper = msg.sender;
    }
    
    // Adds new order to system. Only shipper can create new order
    function newOrder(uint256 _trackingNo, address _recipient, string _notes, string _time) public {
        if (msg.sender != shipper) revert();
        if (trackers[_trackingNo].recipient != 0) revert();
        trackers[_trackingNo] = Tracking(
            shipper,
            _recipient, 
            _time, 
            _notes, 
            OrderStatus.labelCreated);
        
        emit OrderUpdate(
            _trackingNo,
            shipper,
            _recipient, 
            OrderStatus.labelCreated, 
            _notes, 
            _time);
    }
    
    // Updates an order in the system. Only shipper can update new order
    function updateOrder(uint256 _trackingNo, uint _newStatus, string _notes, string _time) public returns (bool) {
        if (msg.sender != shipper) revert();
        if (trackers[_trackingNo].recipient == 0) revert();
        trackers[_trackingNo].orderStatus = OrderStatus(_newStatus);
        trackers[_trackingNo].notes = _notes;
        trackers[_trackingNo].time = _time;
        emit OrderUpdate(
            _trackingNo, 
            shipper,
            trackers[_trackingNo].recipient, 
            trackers[_trackingNo].orderStatus, 
            trackers[_trackingNo].notes, 
            trackers[_trackingNo].time);
        return true;
    }
    
    // beta. creator of contract should still have some power
    function changeShipper(address _provider) public returns (bool) {
        if (_provider == shipper) revert();
        if (_provider == address(0)) revert();
        if (msg.sender != shipper) revert();
        shipper = _provider;
        return true;
    }
    
    function getOrder(uint256 _trackingNo) public view returns (uint256 a, address b, address c, string d, string e, OrderStatus f) {
        if (trackers[_trackingNo].recipient == 0) revert();
        if (trackers[_trackingNo].recipient != msg.sender && msg.sender != shipper) revert();
        a = _trackingNo;
        b = trackers[_trackingNo].provider;
        c = trackers[_trackingNo].recipient;
        d = trackers[_trackingNo].notes;
        e = trackers[_trackingNo].time;
        f = trackers[_trackingNo].orderStatus;
    }
}
