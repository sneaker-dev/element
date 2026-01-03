//
// Copyright 2025 Element Creations Ltd.
// Copyright 2022-2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Compound
import SwiftUI

struct DialPadScreen: View {
    @ObservedObject var context: DialPadScreenViewModel.Context
    
    var body: some View {
        VStack(spacing: 0) {
            phoneNumberDisplay
            dialPadGrid
            dialButton
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.compound.bgCanvasDefault)
        .navigationTitle("Dial")
        .navigationBarTitleDisplayMode(.inline)
        .alert(item: $context.alertInfo)
    }
    
    private var phoneNumberDisplay: some View {
        VStack(spacing: 16) {
            Text(context.viewState.phoneNumber.isEmpty ? "Enter number" : context.viewState.phoneNumber)
                .font(.system(size: 32, weight: .light, design: .default))
                .foregroundColor(context.viewState.phoneNumber.isEmpty ? .compound.textSecondary : .compound.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .padding(.horizontal, 20)
        }
        .padding(.vertical, 32)
    }
    
    private var dialPadGrid: some View {
        VStack(spacing: 20) {
            HStack(spacing: 20) {
                dialPadButton("1", subtitle: "")
                dialPadButton("2", subtitle: "ABC")
                dialPadButton("3", subtitle: "DEF")
            }
            
            HStack(spacing: 20) {
                dialPadButton("4", subtitle: "GHI")
                dialPadButton("5", subtitle: "JKL")
                dialPadButton("6", subtitle: "MNO")
            }
            
            HStack(spacing: 20) {
                dialPadButton("7", subtitle: "PQRS")
                dialPadButton("8", subtitle: "TUV")
                dialPadButton("9", subtitle: "WXYZ")
            }
            
            HStack(spacing: 20) {
                dialPadButton("*", subtitle: "")
                dialPadButton("0", subtitle: "+")
                dialPadButton("#", subtitle: "")
            }
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 20)
    }
    
    private func dialPadButton(_ digit: String, subtitle: String) -> some View {
        Button {
            context.send(viewAction: .appendDigit(digit))
        } label: {
            VStack(spacing: 4) {
                Text(digit)
                    .font(.system(size: 32, weight: .light, design: .default))
                    .foregroundColor(.compound.textPrimary)
                
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.system(size: 12, weight: .regular, design: .default))
                        .foregroundColor(.compound.textSecondary)
                }
            }
            .frame(width: 70, height: 70)
            .background(Color.compound.bgCanvasDefaultLevel1)
            .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
    
    private var dialButton: some View {
        VStack(spacing: 16) {
            Button {
                if context.viewState.phoneNumber.isEmpty {
                    context.send(viewAction: .clear)
                } else {
                    context.send(viewAction: .deleteDigit)
                }
            } label: {
                Image(systemName: context.viewState.phoneNumber.isEmpty ? "xmark.circle.fill" : "delete.left.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.compound.iconPrimary)
                    .frame(width: 50, height: 50)
            }
            .padding(.bottom, 8)
            
            Button {
                context.send(viewAction: .dial)
            } label: {
                Image(systemName: "phone.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.white)
                    .frame(width: 70, height: 70)
                    .background(context.viewState.canDial ? Color.compound.iconAccentTertiary : Color.compound.iconDisabled)
                    .clipShape(Circle())
            }
            .disabled(!context.viewState.canDial)
            .padding(.bottom, 40)
        }
    }
}

