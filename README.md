>

# 🚀 SolidityFund Manager  
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)  
Automatiza el registro de programas benéficos y transferencias seguras de fondos mediante contratos inteligentes en Ethereum.  

---

### 📝 Descripción general  
NGO-FundHub es una solución blockchain para administrar programas de financiación de ONGs con transparencia y seguridad. Permite:  

📋 **Registrar programas** con nombre, patrocinador y monto específico.  
💸 **Transferir fondos** directamente a un contrato secundario auditado.  
🔐 **Retiros seguros** solo para patrocinadores autorizados.  
🔄 Cumplimiento estricto del patrón **Checks-Effects-Interactions (CEI)**.  

**Garantías clave:**  
✅ Fondos bloqueados hasta aprobación del patrocinador  
✅ Registro inmutable de programas en la blockchain  
✅ Acceso restringido mediante roles (Admin/Patrocinador)  

---

### ✨ Características  

#### 📋 Gestión de programas  
- Crear/eliminar programas con datos estructurados.  
- Registro de eventos para auditoría (`ProgramCreated`, `WithdrawCompleted`).  

#### 💸 Seguridad de fondos  
- Transfiere ETH a un contrato hijo en el despliegue.  
- Retiros solo por patrocinadores verificados.  
- Validación de montos exactos (reversión en errores).  

#### 🔍 Transparencia  
- Consulta programas por ID (nombre, patrocinador, monto).  
- Ver saldos en el contrato hijo vía funciones `view`.  

#### 🧩 Diseño modular  
- Contrato hijo actualizable sin afectar datos existentes.  
- Extensible a tokens ERC20 o multisig.  

---

### 📖 Resumen del contrato  

**Funciones principales**  
| 🔧 Función               | 📋 Descripción                                  |  
|-------------------------|-----------------------------------------------|  
| `createProgram()`        | Admin registra programa (nombre, patrocinador, monto). |  
| `withdrawFunds()`        | Patrocinador retira fondos del contrato hijo. |  
| `updateFundReceiver()`   | Admin actualiza dirección del contrato hijo. |  

**Funciones de consulta**  
| 🔍 Función              | 📋 Descripción                          |  
|-------------------------|---------------------------------------|  
| `programs()`            | Devuelve datos completos de un programa. |  
| `getProgramBalance()`   | Consulta saldo en contrato hijo por ID. |  

---

### ⚙️ Requisitos previos  

🛠️ **Herramientas:**  
- [Hardhat](https://hardhat.org/) o [Remix IDE](https://remix.ethereum.org/)  
- [MetaMask](https://metamask.io/) (para pruebas en red)  

🌐 **Entorno:**  
- Compilador Solidity: `^0.8.28`  
- Redes recomendadas: Sepolia, Goerli  

---

### 📄 Licencia  
```solidity
// SPDX-License-Identifier: LGPL-3.0-only
