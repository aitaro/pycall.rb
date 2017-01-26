module PyCall
  module Eval
    Py_eval_input = 258

    def self.eval(str, filename: "pycall")
      globals_ptr = maindict_ptr
      locals_ptr = maindict_ptr
      defer_sigint do
        py_code_ptr = LibPython.Py_CompileString(str, filename, Py_eval_input)
        LibPython.PyEval_EvalCode(py_code_ptr, globals_ptr, locals_ptr)
      end
    end

    class << self
      private

      def maindict_ptr
        LibPython.PyModule_GetDict(PyCall.import_module("__main__"))
      end

      def defer_sigint
        # TODO: should be implemented
        yield
      end
    end
  end

  def self.import_module(name)
    name = name.to_s if name.kind_of? Symbol
    LibPython.PyImport_ImportModule(name) # TODO: fix after introducing PyObject class
  end

  def self.eval(str)
    py_obj_ptr = Eval.eval(str)
    Conversions.convert(py_obj_ptr)
  end
end
