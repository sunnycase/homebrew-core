class LibompAT1200 < Formula
  desc "LLVM's OpenMP runtime library"
  homepage "https://openmp.llvm.org/"
  url "https://github.com/llvm/llvm-project/releases/download/llvmorg-12.0.0/openmp-12.0.0.src.tar.xz"
  sha256 "eb1b7022a247332114985ed155a8fb632c28ce7c35a476e2c0caf865150f167d"
  license "MIT"

  livecheck do
    url "https://llvm.org/"
    regex(/LLVM (\d+\.\d+\.\d+)/i)
  end

  depends_on "cmake" => :build

  on_linux do
    keg_only "provided by LLVM, which is not keg-only on Linux"
  end

  def install
    # Disable LIBOMP_INSTALL_ALIASES, otherwise the library is installed as
    # libgomp alias which can conflict with GCC's libgomp.
    system "cmake", ".", *std_cmake_args, "-DLIBOMP_INSTALL_ALIASES=OFF"
    system "make", "install"
    system "cmake", ".", "-DLIBOMP_ENABLE_SHARED=OFF", *std_cmake_args,
                         "-DLIBOMP_INSTALL_ALIASES=OFF"
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <omp.h>
      #include <array>
      int main (int argc, char** argv) {
        std::array<size_t,2> arr = {0,0};
        #pragma omp parallel num_threads(2)
        {
            size_t tid = omp_get_thread_num();
            arr.at(tid) = tid + 1;
        }
        if(arr.at(0) == 1 && arr.at(1) == 2)
            return 0;
        else
            return 1;
      }
    EOS
    system ENV.cxx, "-Werror", "-Xpreprocessor", "-fopenmp", "test.cpp", "-std=c++11",
                    "-L#{lib}", "-lomp", "-o", "test"
    system "./test"
  end
end
