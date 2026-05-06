//
//  energyBalance.swift
//  FlowLab
//
//  Created by Алексей Езерский on 24.05.2026.
//

//MARK: - Расчет интегрального баланса энергии, New scheme
/*
import Foundation
extension NavierStokesSolver {
    /// Выводит невязку сохранения энергии в EPM и сравнивает с ALE. Для работы добавьте в класс свойство var total_heat_entered_EPM = 0.0
    func calculateEnergyBalance() {
        let nx = self.nx, ny = self.ny, h = self.h
        let h2 = h * h, inv_2h = 1 / (2.0 * h)
        let rho_sol = rho_solid, Cp_liq = Cp, Cp_sol = Cp_solid
        let L = latentHeat, lambda_liq = lambda(T_melt), rho = rho
        let dTime = self.dTime

        // Интегрируем накопленный поток внутри жидкой фазы
        var energy_sensible = 0.0
        var energy_latent = 0.0
        for idx in 0..<(nx * ny) {
            let f = liquidFraction[idx]
            let Cp_eff = f * Cp_liq + (1.0 - f) * Cp_sol
            let rho_eff = f * rho + (1.0 - f) * rho_sol
            energy_sensible += rho_eff * Cp_eff * (T[idx] - T_cold) * h2
            energy_latent += rho_sol * L * f * h2
        }
        let total_energy_EPM = energy_sensible + energy_latent
        
        // Интегрируем входящий поток через левую горячую стенку (i=0)
        var inst_flux_left = 0.0
        for j in 1..<(ny - 1) {
            let idx0 = j * nx
            let idx1 = idx0 + 1
            let idx2 = idx0 + 2
            let q_row = lambda_liq * (3.0 * T[idx0] - 4.0 * T[idx1] + T[idx2]) * inv_2h ///[W/m²]
            inst_flux_left += q_row * h
        }
        total_heat_entered_EPM += inst_flux_left * dTime ///[J = W•s]
        
        let internal_error = abs(total_energy_EPM - total_heat_entered_EPM) / (total_heat_entered_EPM + tiny) * 100
        
        print("--- БАЛАНС (Время: \(String(format: "%.2f", time)) c) ---")
        print("EPM Накоплено = \(Int(total_energy_EPM)) Дж | Зашло = \(Int(total_heat_entered_EPM)) Дж (Погрешность: \(String(format: "%.3f", internal_error))%)")
        
    }

}
*/
