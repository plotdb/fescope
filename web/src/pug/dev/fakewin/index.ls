p = new proxin!

code = """
console.log("code executed");
function mycls() {
  this.name = "mycls";
  return this;
}
"""
p.wrap code
