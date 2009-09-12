module m_wkml_color

  use FoX_wxml
  use FoX_common

  use m_wkml_color_def, only: colorArray

  implicit none
  private

  type color_t
    private
    character(len=8) :: hex
  end type color_t


  integer, parameter :: defaultAlpha = 249

  type(color_t), parameter :: defaultCI(5) = &
    (/color_t('eef00000'), color_t('eeb00030'), &
    color_t('ee700070'), color_t('ee3000b0'), color_t('ee0000f0')/)

  character(len=*), parameter :: hexdigits = '0123456789abcdefABCDEF'

  interface kmlGetCustomColor
    module procedure kmlGetColor_index
    module procedure kmlGetColor_byName
  end interface kmlGetCustomColor

  interface kmlAddColor
    module procedure kmlAddColor_c
    module procedure kmlAddColor_h
  end interface kmlAddColor

  interface kmlAddBgColor
    module procedure kmlAddBgColor_c
    module procedure kmlAddBgColor_h
  end interface kmlAddBgColor

  interface kmlAddTextColor
    module procedure kmlAddTextColor_c
    module procedure kmlAddTextColor_h
  end interface kmlAddTextColor

  public :: color_t
  public :: defaultCI

  public :: kmlGetCustomColor
  public :: kmlSetCustomColor

  public :: kmlGetColorHex

  public :: kmlAddColor
  public :: kmlAddBgColor
  public :: kmlAddTextColor

! this one is used for MCHSIM like coloring
  public :: kmlMakeColorMap

contains

  function checkColorHex(h) result(p)
    character(len=8) :: h
    logical :: p
    p = (verify(h, hexdigits)==0)
  end function checkColorHex
      

  subroutine kmlAddColor_c(xf, col)
    type(xmlf_t), intent(inout) :: xf
    type(color_t), intent(in) :: col

    call xml_NewElement(xf, 'color')
    call xml_AddCharacters(xf, col%hex)
    call xml_EndElement(xf, 'color')
  end subroutine kmlAddColor_c


  subroutine kmlAddColor_h(xf, col)
    type(xmlf_t), intent(inout) :: xf
    character(len=8), intent(in) :: col
    integer, pointer :: p
    
    if (.not.checkColorHex(col)) then
      print*, col
      print*, verify(col, hexdigits)
      print*, "Invalid color value"
      nullify(p)
      print*, p
    endif

    call xml_NewElement(xf, 'color')
    call xml_AddCharacters(xf, col)
    call xml_EndElement(xf, 'color')
  end subroutine kmlAddColor_h

  subroutine kmlAddBgColor_c(xf, col)
    type(xmlf_t), intent(inout) :: xf
    type(color_t), intent(in) :: col

    call xml_NewElement(xf, 'bgColor')
    call xml_AddCharacters(xf, col%hex)
    call xml_EndElement(xf, 'bgColor')
  end subroutine kmlAddBgColor_c


  subroutine kmlAddBgColor_h(xf, col)
    type(xmlf_t), intent(inout) :: xf
    character(len=8), intent(in) :: col

    if (.not.checkColorHex(col)) then
      print*, "Invalid color value"
      stop
    endif

    call xml_NewElement(xf, 'bgColor')
    call xml_AddCharacters(xf, col)
    call xml_EndElement(xf, 'bgColor')
  end subroutine kmlAddBgColor_h

  subroutine kmlAddTextColor_c(xf, col)
    type(xmlf_t), intent(inout) :: xf
    type(color_t), intent(in) :: col

    call xml_NewElement(xf, 'textcolor')
    call xml_AddCharacters(xf, col%hex)
    call xml_EndElement(xf, 'textcolor')
  end subroutine kmlAddTextColor_c


  subroutine kmlAddTextColor_h(xf, col)
    type(xmlf_t), intent(inout) :: xf
    character(len=8), intent(in) :: col

    if (.not.checkColorHex(col)) then
      print*, "Invalid color value"
      stop
    endif

    call xml_NewElement(xf, 'textcolor')
    call xml_AddCharacters(xf, col)
    call xml_EndElement(xf, 'textcolor')
  end subroutine kmlAddTextColor_h


  subroutine kmlSetCustomColor(myCI, colorhex)
    type(color_t), intent(out) :: myCI
    character(len=8), intent(in) :: colorhex

    if (.not.checkColorHex(colorhex)) then
      print*, "Invalid color value"
      stop
    endif

    myCI%hex = colorhex

  end subroutine kmlSetCustomColor

  function kmlGetColorHex(col) result(h)
    type(color_t), intent(in) :: col
    character(len=8) :: h
    h = col%hex
  end function kmlGetColorHex

  function kmlGetColor_index(i) result(c)
    integer, intent(in) :: i
    type(color_t) :: c

    if (i>size(colorArray).or.(i<1)) then
      print*, "Invalid index in kmlGetColor (by index)"
      stop
    endif
    
    ! Note - 'x2' argument is the format string
    c%hex = str(defaultAlpha, 'x2')//str(colorArray(i)%b, 'x2') &
      //str(colorArray(i)%g, 'x2')//str(colorArray(i)%r, 'x2')

  end function kmlGetColor_index

  function kmlGetColor_byName(name) result(c)
    character(len=*), intent(in) :: name
    type(color_t) :: c

    integer :: i
    logical :: found

    found = .false.
    do i = 1, size(colorArray)
      if (trim(colorArray(i)%name)==name) then
        c%hex = str(defaultAlpha, 'x2')//str(colorArray(i)%b, 'x2') &
          //str(colorArray(i)%g, 'x2')//str(colorArray(i)%r, 'x2')
        found = .true.
      endif
    enddo

    if (.not.found) then
      print*, "Invalid name in kmlGetColor (by name)"
      stop
    endif

  end function kmlGetColor_byName

  function kmlMakeColorMap(numcolors, start, finish) result(colormap)
    integer, intent(in) :: numcolors
    type(color_t), intent(in), optional :: start, finish
    type(color_t), pointer :: colormap(:)

    integer :: i, red, blue

    if (present(start).neqv.present(finish)) then
      print*, 'Must specify both of start and finish in kmlMakeColorMap'
    endif

    ! FIXME do something with start & finish
    allocate(colormap(numcolors))
    do i = 1, numcolors
      red = (256.0/numcolors)*i-1
      blue = 256 - red
      colormap(i)%hex = "e0"//str(blue, "x2")//40//str(red, "x2")
    enddo
  end function kmlMakeColorMap



end module m_wkml_color
