import SwiftUI

struct Home: View{
    // MARK: GlassMorphism Properties
    @State var blurView: UIVisualEffectView = .init()
    @State var defaultBlurRadius: CGFloat = 0
    @State var defaultSaturationAmount: CGFloat = 0
    
    //@State var progress: CGFloat = 0
    @State var activateGlassMorphism: Bool = false
    
    var body: some View{
        ZStack{
            Color(.black)
                .ignoresSafeArea()
        
            Image(systemName: "scribble.variable")
                .foregroundColor(.cyan)
                .font(.system(size: 200))
            
            GlassMorphicCard()
            
            
            // MARK: Slider to show Demo
//            Slider(value: $progress, in: 1...15)
//                .onChange(of: progress){newValue in
//                    blurView.gaussianBlurRadius = newValue
//                }
            //                .frame(maxHeight: .infinity, alignment: .bottom)
            //                .padding(15)
            Toggle("Activate Glass Morphism", isOn: $activateGlassMorphism)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .onChange(of: activateGlassMorphism){newValue in
                    // Change Blur radius and saturation
                    blurView.gaussianBlurRadius = (activateGlassMorphism ? 10 : defaultBlurRadius)
                    blurView.saturationAmount = (activateGlassMorphism ? 1.8 : defaultSaturationAmount)
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(15)
            
            
            
        }
        
    }
    
    // MARK: GlassMorphism Card
    @ViewBuilder
    func GlassMorphicCard()->some View{
        ZStack{
            CustomBlurView(effect: .systemUltraThinMaterialDark){ view in
                blurView = view
                if defaultBlurRadius == 0{defaultBlurRadius = view.gaussianBlurRadius}
                if defaultSaturationAmount == 0{defaultSaturationAmount = view.saturationAmount}
            }
            .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
            
            // MARK: building glassmorphic card
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(.linearGradient(colors: [
                    .white.opacity(0.25),
                    .white.opacity(0.05),
                    .clear
                ], startPoint: .topLeading, endPoint: .bottomTrailing)
                ).blur(radius: 5)
            
            // MARK: Borders
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .stroke(.linearGradient(colors: [
                    .white.opacity(0.6),
                    .clear,
                    .cyan.opacity(0.2),
                    .cyan.opacity(0.5)
                ], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 2
                )
        }
        // MARK: Shadow
        .shadow(color: .black.opacity(0.15), radius: 5, x: -10, y: 10)
        .shadow(color: .black.opacity(0.15), radius: 5, x: 10, y: -10)
        .overlay(content: {
            // Card content
            CardContent()
                .opacity(activateGlassMorphism ? 1 : 0)
                .animation(.easeIn(duration: 0.2), value: activateGlassMorphism)
        })
        .padding(.horizontal, 25)
        .frame(height: 220)
    }
    
    @ViewBuilder
    func CardContent() -> some View{
        VStack(alignment: .leading, spacing: 12){
            HStack(){
                Text("MEMBERSHIP")
                    .modifier(CustomModifier(font: .callout))
                Image(systemName: "creditcard")
                    .foregroundColor(.white)
                    .font(.system(size: 32))

            }
            Spacer()
            
            Text("KENTARO MIHARA")
                .modifier(CustomModifier(font: .title3))
            Text("kenmaro")
                .modifier(CustomModifier(font: .callout))
            
        }
        .padding(20)
        .padding(.vertical, 10)
        .blendMode(.overlay)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

// MARK: Custom Modifier since most of the text shares same modifier
struct CustomModifier: ViewModifier{
    var font: Font
    func body(content: Content) -> some View{
        content
            .font(font)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .kerning(1.2)
            .shadow(radius: 15)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}


struct Home_Previews: PreviewProvider{
    static var previews: some View{
        ContentView()
    }
}


// MARK: Custom Blur View
// With the help of UiVisualEffect View
struct CustomBlurView: UIViewRepresentable{
    var effect: UIBlurEffect.Style
    var onChange: (UIVisualEffectView) -> ()
    
    func makeUIView(context: Context) -> UIVisualEffectView{
        let view = UIVisualEffectView(effect: UIBlurEffect(style: effect))
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context){
        DispatchQueue.main.async{
            onChange(uiView)
        }
    }
}


// MARK: Adjusting Blur Radius in UIVisualEffectView
extension UIVisualEffectView{
    // MARK: steps
    // Extracting private class BackDropView class
    // Then from that view extracting ViewEffects like gaussian blur & saturation
    // with the help of this we can achieve class morphism
    var backDrop: UIView?{
        // Private class
        return subView(forClass: NSClassFromString("_UIVisualEffectBackdropView"))
    }
    
    // MARK: Extracting Gaussian Blur From BackDropView
    var gaussianBlur: NSObject?{
        backDrop?.value(key: "filters", filter: "gaussianBlur")
    }
    
    
    // MARK: Extracting Saturation from backDropView
    var saturation: NSObject?{
        return backDrop?.value(key: "filters", filter: "colorSaturate")
    }
    
    // MARK: Updating Blur radius and saturation
    var gaussianBlurRadius: CGFloat{
        get{
            // MARK: we know the key for gaussian blur = "inputRadius"
            return gaussianBlur?.values?["inputRadius"] as? CGFloat ?? 0
        }
        set{
            gaussianBlur?.values?["inputRadius"] = newValue
            // Updating the backDrop view with the new filter updates
            applyNewEffects()
            
        }
    }
    
    func applyNewEffects(){
        // MARK: Animating the change
        UIVisualEffectView.animate(withDuration: 0.2){
            self.backDrop?.perform(Selector("applyRequestedFilterEffects"))
        }
    }
    
    var saturationAmount: CGFloat{
        get{
            // MARK: we know the key for gaussian blur = "inputAmount"
            return saturation?.values?["inputAmount"] as? CGFloat ?? 0
        }
        set{
            saturation?.values?["inputAmount"] = newValue
            applyNewEffects()
            
        }
    }
    
}

// MARK: Finding subview for class
extension UIView{
    func subView(forClass: AnyClass?) -> UIView?{
        return subviews.first{view in
            type(of: view) == forClass
        }
    }
}


// MARK: Custom key filtering
extension NSObject{
    // MARK: key values from NSOBject
    var values: [String: Any]?{
        get{
            return value(forKeyPath: "requestedValues") as? [String: Any]
        }
        set{
            setValue(newValue, forKeyPath: "requestedValues")
        }
    }
    func value(key: String, filter: String) -> NSObject?{
        (value(forKey: key) as? [NSObject])?.first(where: {obj in
            return obj.value(forKeyPath: "filterType") as? String == filter
        })
    }
}
