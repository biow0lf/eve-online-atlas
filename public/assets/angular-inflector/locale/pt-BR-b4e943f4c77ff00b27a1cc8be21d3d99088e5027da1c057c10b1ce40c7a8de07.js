!function(e,t){"use strict";e.module("platanus.inflector").config(["inflectorProvider",function(e){e.registerLocale("pt-BR",{uncountable:["t\xf3rax","t\xeanis","\xf4nibus","l\xe1pis","f\xeanix"],plural:[[new RegExp("^(japon|escoc|ingl|dinamarqu|fregu|portugu)(es|\xeas)","gi"),"$1eses"],[new RegExp("([^aeou])il$","gi"),"$1is"],[new RegExp("^(pa\xed)s$","gi"),"$1ses"],[new RegExp("(z|r)$","gi"),"$1es"],[new RegExp("al$","gi"),"ais"],[new RegExp("el$","gi"),"eis"],[new RegExp("ol$","gi"),"ois"],[new RegExp("ul$","gi"),"uis"],[new RegExp("m$","gi"),"ns"],[new RegExp("^(|g)\xe1s$","gi"),"$1ases"],[new RegExp("^(alem|c|p)\xe3o$","gi"),"$1\xe3es"],[new RegExp("(irm|m)\xe3o$","gi"),"$1\xe3os"],[new RegExp("\xe3o$","gi"),"$1\xf5es"],[new RegExp("^(alem|c|p)ao$","gi"),"$1aes"],[new RegExp("^(irm|m)ao$","gi"),"$1aos"],[new RegExp("ao$","gi"),"oes"],[new RegExp("s$","gi"),"s"],[new RegExp("$","gi"),"s"]],singular:[[new RegExp("^(\xe1|g\xe1|pa\xed)ses$","gi"),"$1s"],[new RegExp("(r|z)es$","gi"),"$1"],[new RegExp("([^p])ais$","gi"),"$1al"],[new RegExp("eis$","gi"),"el"],[new RegExp("ois$","gi"),"ol"],[new RegExp("uis$","gi"),"ul"],[new RegExp("(r|t|f|v)is$","gi"),"$1il"],[new RegExp("ns$","gi"),"m"],[new RegExp("sses$","gi"),"sse"],[new RegExp("^(.*[^s]s)es$","gi"),"$1"],[new RegExp("\xe3es$","gi"),"\xe3o"],[new RegExp("aes$","gi"),"ao"],[new RegExp("\xe3os$","gi"),"\xe3o"],[new RegExp("aos$","gi"),"ao"],[new RegExp("\xf5es$","gi"),"ao"],[new RegExp("oes$","gi"),"ao"],[new RegExp("(japon|escoc|ingl|dinamarqu|fregu|portugu)eses$","gi"),"$1es"],[new RegExp("^(g|)ases$","gi"),"$1as"],[new RegExp("([^\xea])s$","gi"),"$1"],[new RegExp("s$","gi"),""]]})}])}(angular);