// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.28;

import "./Interfaces/IOng1.sol";

contract Ong {
    // Dirección del propietario del contrato
    address public owner;
    
    // Contador para IDs de programas
    uint256 private nextProgramId = 1;
    
    // Estructura de datos para programas
    struct Program {
        uint256 id;          // Identificador único
        string name;         // Nombre del programa
        address sponsor;    // Dirección del patrocinador
        uint256 initialAmount; // Monto inicial de fondos
        bool active;        // Estado del programa
        address fundReceiver; // Dirección del contrato receptor
    }
    
    // Mapeo de programas por ID
    mapping(uint256 => Program) public programs;
    
    // Mapeo para evitar nombres duplicados
    mapping(string => bool) private programExists;
    
    // Eventos para seguimiento en blockchain
    event ProgramCreated(uint256 indexed id, string name, address sponsor, uint256 amount, address fundReceiver);
    event ProgramDeleted(uint256 indexed id);
    event WithdrawalCompleted(uint256 indexed id, address sponsor, uint256 amount);

    // Modificador para restringir funciones al propietario
    modifier onlyOwner() {
        require(msg.sender == owner, "Solo el propietario");
        _;
    }

    // Constructor: Inicializa el propietario
    constructor() {
        owner = msg.sender;
    }

    // Función para crear nuevos programas (solo owner)
    function createProgram(
        string memory _name,
        address _sponsor,
        uint256 _amount
    ) external payable onlyOwner {
        // Validaciones iniciales
        require(msg.value == _amount, "Monto no coincide");
        require(_sponsor != address(0), "Sponsor invalido");
        require(bytes(_name).length > 0, "Nombre requerido");
        require(!programExists[_name], "Programa ya existe");
        
        // Actualización de estado
        programExists[_name] = true;
        uint256 programId = nextProgramId++;
        
        // Creación del contrato receptor (IOng1)
        IOng1 fundReceiverInstance = new FundReceiver(address(this));
        
        // Transferencia de fondos y registro de datos
        payable(address(fundReceiverInstance)).transfer(msg.value);
        fundReceiverInstance.receiveProgramData{value: msg.value}(programId, _name, _sponsor, _amount);
        
        // Almacenamiento del programa
        programs[programId] = Program({
            id: programId,
            name: _name,
            sponsor: _sponsor,
            initialAmount: _amount,
            active: true,
            fundReceiver: address(fundReceiverInstance)
        });

        emit ProgramCreated(programId, _name, _sponsor, _amount, address(fundReceiverInstance));
    }

    // Función para retiro de fondos por patrocinadores
    function withdrawFunds(uint256 _programId) external {
        Program storage program = programs[_programId];
        
        // Validaciones de seguridad
        require(program.active, "Programa inactivo");
        require(msg.sender == program.sponsor, "No autorizado");
        
        // Interacción con contrato receptor
        IOng1 fundReceiverInstance = IOng1(payable(program.fundReceiver));
        uint256 availableFunds = fundReceiverInstance.getBalance(_programId);
        require(availableFunds > 0, "Sin fondos disponibles");
        
        // Actualización de estado antes de interacción
        program.active = false;
        
        // Retiro de fondos
        fundReceiverInstance.withdrawFunds(_programId, payable(msg.sender), availableFunds);
        
        emit WithdrawalCompleted(_programId, msg.sender, availableFunds);
    }
}

// Implementación mejorada del contrato receptor
contract FundReceiver is IOng1 {
    address public immutable mainContract;
    
    struct ProgramData {
        uint256 balance;
        address sponsor;
        bool active;
    }
    
    mapping(uint256 => ProgramData) public programs;

    constructor(address _mainContract) {
        require(_mainContract != address(0));
        mainContract = _mainContract;
    }

    function receiveProgramData(
        uint256 _id,
        string calldata,
        address _sponsor,
        uint256 _amount
    ) external payable override {
        require(msg.sender == mainContract, "Llamada no autorizada");
        programs[_id] = ProgramData(_amount, _sponsor, true);
    }

    function withdrawFunds(
        uint256 _id,
        address payable _sponsor,
        uint256 _amount
    ) external override {
        require(msg.sender == mainContract, "Llamada no autorizada");
        ProgramData storage program = programs[_id];
        
        require(program.active, "Programa inactivo");
        require(program.balance >= _amount, "Fondos insuficientes");
        require(_sponsor == program.sponsor, "Patrocinador no coincide");
        
        program.balance -= _amount;
        (bool success, ) = _sponsor.call{value: _amount}("");
        require(success, "Transferencia fallida");
    }

    function getBalance(uint256 _id) external view override returns (uint256) {
        return programs[_id].balance;
    }

    receive() external payable {}
}
