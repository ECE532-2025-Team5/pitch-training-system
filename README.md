# 🧠 Finite State Machine (FSM) – MicroBlaze

This section documents the development and refinement of the **Finite State Machine (FSM)** used in the MicroBlaze processor for this project. The FSM is responsible for controlling system behavior based on encoded data exchanged with the hardware and audio pipelines.

---

## 📁 Files

### ✅ `working_fsm_prototype.c`
- A **prototype FSM** used primarily for testing and validation.
- Uses **14 bits of onboard LEDs** to output real-time comparison results.
- Demonstrates the effectiveness of **encoded data communication** between MicroBlaze and peripheral components during integration.
- Verified **logical correctness** of the FSM state transitions.

🔧 **Implementation Tip:**
- If you want the FSM to **remain in a state while waiting for new inputs**, use **`do-while` loops** instead of regular `while` loops.  
- Example: See **lines 120–179** in this file for a correct usage of `do-while`.

---

### 🛠️ `modify_for_integration_fsm.c`
- Builds on the foundation of `working_fsm_prototype.c`.
- Enhanced for use in the **final system design**, with integration support for **input from both hardware and audio pipelines**.
- All necessary modifications were made to support **real-time control and data flow** in the final integrated setup.

---

## 🧾 Summary

These FSM implementations are a critical part of ensuring coordinated communication and state control across the MicroBlaze system. By encoding and decoding control data effectively, we streamlined integration and modular testing during development.

