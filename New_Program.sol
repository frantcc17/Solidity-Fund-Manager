// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "./Interfaces/IOng1.sol";

contract FundReceiver is IOng1 {
    // Dirección del propietario del contrato
    address public owner;
    
    // Estructura para almacenar datos de fondos
    struct FundData {
        uint256 id;         // Identificador único del programa
        string name;        // Nombre del programa benéfico
        address sponsor;    // Dirección del patrocinador
        uint256 balance;    // Balance actual del programa
    }
    
    // Mapeo de programas por ID
    mapping(uint256 => FundData) public funds;
    
    // Mapeo de retiros pendientes por dirección
    mapping(address => uint256) public pendingWithdrawals;
    
    // Eventos para seguimiento en blockchain
    event FundsReceived(uint256 indexed id, uint256 amount);
    event FundsWithdrawn(uint256 indexed id, address to, uint256 amount);

    // Modificador para restringir funciones al propietario
    modifier onlyOwner() {
        require(msg.sender == owner, "Solo el propietario");
        _;
    }

    // Constructor: Inicializa el propietario del contrato
    constructor() {
        owner = msg.sender;
    }

    // Función para recibir fondos y datos de programas (Implementa IOng1)
    function receiveProgramData(
        uint256 _id,
        string calldata _name,
        address _sponsor,
        uint256 _amount
    ) external payable override {
        // Verificación crítica de seguridad
        require(msg.value == _amount, "Monto no coincide");
        
        // Lógica de creación/actualización de fondos
        if (funds[_id].balance == 0) {
            funds[_id] = FundData({
                id: _id,
                name: _name,
                sponsor: _sponsor,
                balance: _amount
            });
        } else {
            // Actualización segura del balance
            funds[_id].balance += _amount;
        }
        
        emit FundsReceived(_id, _amount);
    }

    // Función para autorizar retiros (solo owner)
    function withdrawFunds(
        uint256 _id,
        address payable _sponsor,
        uint256 _amount
    ) external override onlyOwner {
        FundData storage data = funds[_id];
        
        // Validaciones de seguridad
        require(data.balance >= _amount, "Fondos insuficientes");
        
        // Actualización del estado antes de la interacción
        data.balance -= _amount;
        pendingWithdrawals[_sponsor] += _amount;
        
        emit FundsWithdrawn(_id, _sponsor, _amount);
    }

    // Función para que los usuarios reclamen sus fondos
    function claimFunds() external {
        // Verificación de fondos pendientes
        uint256 amount = pendingWithdrawals[msg.sender];
        require(amount > 0, "No hay fondos pendientes");
        
        // Patrón Checks-Effects-Interactions
        pendingWithdrawals[msg.sender] = 0;
        
        // Transferencia segura usando call
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transferencia fallida");
    }

    // Función para consultar balance (maneja casos de fondos insuficientes)
    function getBalance(uint256 _id) external view override returns (uint256) {
        return address(this).balance < funds[_id].balance 
            ? address(this).balance 
            : funds[_id].balance;
    }

    // Función de emergencia para recuperar fondos (solo owner)
    function emergencyWithdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No hay fondos");
        
        (bool success, ) = owner.call{value: balance}("");
        require(success, "Fallo al retirar fondos");
    }

    // Función para recibir ETH directamente
    receive() external payable {}
}
