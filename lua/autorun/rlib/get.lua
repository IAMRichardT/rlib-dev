/*
*   @package        : rlib
*   @author         : Richard [http://steamcommunity.com/profiles/76561198135875727]
*   @copyright      : (C) 2020 - 2020
*   @since          : 3.0.0
*   @website        : https://rlib.io
*   @docs           : https://docs.rlib.io
* 
*   MIT License
*
*   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT 
*   LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
*   IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
*   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION 
*   WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

/*
*   standard tables and localization
*/

rlib                    = rlib or { }
local base              = rlib
local mf                = base.manifest
local prefix            = mf.prefix
local cfg               = base.settings

/*
*   localized rlib routes
*/

local helper            = base.h

/*
*   Localized lua funcs
*
*   i absolutely hate having to do this, but for squeezing out every
*   bit of performance, we need to.
*/

local pairs             = pairs
local GetConVar         = GetConVar
local tonumber          = tonumber
local IsValid           = IsValid
local istable           = istable
local isnumber          = isnumber
local isstring          = isstring
local type              = type
local debug             = debug
local util              = util
local table             = table
local string            = string
local sf                = string.format

/*
*   Localized translation func
*/

local function lang( ... )
    return base:lang( ... )
end

/*
*   simplifiy funcs
*/

local function log( ... ) base:log( ... ) end

/*
*   get :: workshops
*
*   returns workshops that are loaded on the server through the various methods including rlib, rcore,
*   and individual modules.
*
*   @param  : tbl src
*   @return : tbl
*/

    function base.get:ws( src )
        return istable( src ) and src or base.w
    end

/*
*   get :: version
*
*   returns the current running version of a specified manifest
*   no args = rlib version
*
*   @since  : v1.1.5
*   @param  : tbl, str mnfst
*   @param  : bool bLibReq
*   @return : tbl
*           : major, minor, patch
*/

    function base.get:version( mnfst, bLibReq )
        mnfst = ( isstring( mnfst ) or istable( mnfst ) and mnfst ) or mf

        local src = ( ( not bLibReq and ( istable( mnfst.version ) or isstring( mnfst.version ) ) ) and mnfst.version ) or ( ( bLibReq and ( istable( mnfst.libreq ) or isstring( mnfst.libreq ) ) ) and mnfst.libreq )

        if isstring( src ) then
            local ver = string.Explode( '.', src )
            return {
                [ 'major' ] = ver[ 'major' ] or ver[ 1 ] or 1,
                [ 'minor' ] = ver[ 'minor' ] or ver[ 2 ] or 0,
                [ 'patch' ] = ver[ 'patch' ] or ver[ 3 ] or 0
            }
        elseif istable( src ) then
            return {
                [ 'major' ] = src.major or src[ 1 ] or 1,
                [ 'minor' ] = src.minor or src[ 2 ] or 0,
                [ 'patch' ] = src.patch or src[ 3 ] or 0
            }
        end
        return {
            [ 'major' ] = 1,
            [ 'minor' ] = 0,
            [ 'patch' ] = 0
        }
    end

/*
*   get :: version 2 string :: manifest
*
*   returns the current running version of a specified manifest in human readable format
*
*   @param  : tbl mnfst
*   @param  : str char
*   @return : str
*/

    function base.get:ver2str_mf( mnfst, char )
        mnfst   = ( isstring( mnfst ) or istable( mnfst ) and mnfst ) or mf
        char    = isstring( char ) and char or '.'

        if isstring( mnfst.version ) then
            return mnfst.version
        elseif istable( mnfst.version ) then
            local major, minor, patch = mnfst.version.major or mnfst.version[ 1 ] or 1, mnfst.version.minor or mnfst.version[ 2 ] or 0, mnfst.version.patch or mnfst.version[ 3 ] or 0
            return sf( '%i%s%i%s%i', major, char, minor, char, patch )
        end

        return '1.0.0'
    end

/*
*   get :: version 2 string
*
*   converts an rlib version table to human readable format
*
*   @note   : will replace get:version and get:ver2str soon
*
*   @ex     : { 3, 0, 2 }
*             3.0.2
*
*   @return : str
*/

    function base.get:ver2str( src )
        if isstring( src ) then
            return src
        elseif istable( src ) then
            local major, minor, patch = src.major or src[ 1 ] or 1, src.minor or src[ 2 ] or 0, src.patch or src[ 3 ] or 0
            return sf( '%i.%i.%i', major, minor, patch )
        end

        return '1.0.0'
    end

/*
*   base :: get :: structured
*
*   returns version tbl as table with major, minor, patch keys
*
*   @ex     : rlib.get:ver_struct( { 1, 4, 5 } )
*
*   @since  : v3.0.0
*   @param  : tbl ver
*   @return : tbl
*/

    function base.get:ver_struct( ver )
        return {
            [ 'major' ] = ( ver and ver[ 'major' ] or ver[ 1 ] ) or 1,
            [ 'minor' ] = ( ver and ver[ 'minor' ] or ver[ 2 ] ) or 0,
            [ 'patch' ] = ( ver and ver[ 'patch' ] or ver[ 3 ] ) or 0
        }
    end

/*
*   helper :: get :: ver :: package
*
*   returns version tbl as string for rlib packages such as rhook,
*   timex, calc, etc.
*
*   @ex     : rlib.get.ver_pkg( { 1, 4, 5 } )
*   @ret    : 1.4.5
*
*   @param  : tbl ver
*   @return : str
*/

    function base.get:ver_pkg( src )
        if not src then return '1.0.0' end
        return ( src and src.__manifest and self:ver2str( src.__manifest.version ) ) or { 1, 0, 0 }
    end

/*
*   get :: os
*
*   return the operating system for the server the script is running on
*
*   @return : str, int
*/

    function base.get:os( )
        if system.IsWindows( ) then
            return lang( 'sys_os_windows' ), 1
        elseif system.IsLinux( ) then
            return lang( 'sys_os_linux' ), 2
        else
            return lang( 'sys_os_ukn' ), 0
        end
    end

/*
*   get :: host
*
*   return the server hostname
*
*   @param  : bool bClean
*   @param  : bool bLower
*   @return : str
*/

    function base.get:host( bClean, bLower )
        local host = GetHostName( )

        if bClean then
            host = host:gsub( '[^%w ]', '' )    -- replace all special chars
            host = host:gsub( '[%s]', '_' )     -- replace all spaces
            host = host:gsub( '%_%_+', '_' )    -- replace repeating underscores
        end

        if bLower then
            host = host:lower( )
        end

        return host or lang( 'sys_host_untitled' )
    end

/*
*   get :: address
*
*   return the current ip address and port for the server
*
*   @return : str
*/

    function base.get:addr( )
        return helper.str:split_addr( game.GetIPAddress( ) )
    end

/*
*   get :: gamemode
*
*   return the server gamemode
*
*   @param  : bool bCombine
*   @param  : bool bLower
*   @param  : bool bClean
*   @return : str, str
*/

    function base.get:gm( bCombine, bLower, bClean )
        local gm_name = ( GM or GAMEMODE ).Name or lang( 'sys_gm_unknown' )
        local gm_base = ( GM or GAMEMODE ).BaseClass.Name or lang( 'sys_gm_sandbox' )

        -- some darkrp derived gamemodes are marked as sandbox / base
        gm_base = ( istable( DarkRP ) and lang( 'sys_gm_darkrp' ) ) or gm_base

        if bCombine then
            gm_name = sf( '%s [ %s ]', gm_name, gm_base )
        end

        if bClean then
            gm_name = gm_name:gsub( '[%p%c%s]', '_' )
        end

        return bLower and gm_name:lower( ) or gm_name, bLower and gm_base:lower( ) or gm_base
    end

/*
*   get :: hash
*
*   create hash from server ip and port
*
*   @return : str
*/

    function base.get:hash( )
        local ip, port = self:addr( )
        if not ip then return end

        port        = port or '27015'
        local cs    = util.CRC( sf( '%s:%s', ip, port ) )

        return sf( '%x', cs )
    end

/*
*   get :: server ip
*
*   return server ip
*
*           :   char
*               if bool and true; will replace separate segments with |
*               if str provided, that will be used as separator
*
*   @usage  : base.get:ip( '-' )
*             returns 127-0-0-1
*
*           : base.get:ip( true )
*             returns 127|0|0|1
*
*           : base.get:ip( )
*             returns 127.0.0.1
*
*   @param  : str, bool char
*   @return : str
*/

    function base.get:ip( char )
        local ip    = game.GetIPAddress( )
        local e     = string.Explode( ':', ip )
        sep         = ( isstring( char ) and char ) or ( isbool( char ) and char == true and '|' ) or '.'
        local resp  = e[ 1 ]:gsub( '[%p]', sep )

        return resp
    end

/*
*   get :: server port
*
*   returns server port
*
*   @return : str
*/

    function base.get:port( )
        local port = GetConVar( 'hostport' ):GetInt( )
        if port and port ~= 0 then
            return port
        else
            local ip    = game.GetIPAddress( )
            local e     = string.Explode( ':', ip )
            port        = e[ 2 ]

            return port
        end
    end

/*
*   get :: prefix
*
*   creates a proper str id based on the params provided
*   should be called through a localized function
*
*   local function pref( str, suffix )
*       local state = not suffix and mod or isstring( suffix ) and suffix or false
*       return rlib.get:pref( str, state )
*   end
*
*   @call   : pref( 'pnl.root' )
*             returns 'modname.pnl.root'
*
*           : pref( 'pnl.root', true )
*             returns 'rlib.pnl.root'
*
*           : pref( 'pnl.root', 'test' )
*             returns 'test.pnl.root'
*
*   @param  : str id
*   @param  : tbl, str, bool suffix
*   @return : str
*/

    function base.get:pref( id, suffix )
        local affix     = istable( suffix ) and suffix.id or isstring( suffix ) and suffix or prefix
        affix           = affix:sub( -1 ) ~= '.' and sf( '%s.', affix ) or affix

        id              = isstring( id ) and id or 'noname'
        id              = id:gsub( '[%p%c%s]', '.' )

        return sf( '%s%s', affix, id )
    end

/*
*   base :: parent owners
*
*   fetches the parent script owners to use in a table
*
*   @ex     : local owners = rlib.get:owners( )
*
*   @param  : tbl source
*/

    function base.get:owners( source )
        source = source or base.plugins or { }

        if not istable( source ) then
            log( 2, 'missing table for » [ %s ]', debug.getinfo( 1, 'n' ).name )
            return false
        end

        for v in helper.get.data( source ) do
            if not v.manifest.owner then continue end
            if type( v.manifest.owner ) == 'string' then
                if helper.ok.sid64( v.manifest.owner ) and not table.HasValue( base.o, v.manifest.owner ) then
                    table.insert( base.o, v.manifest.owner )
                end
            elseif type( v.manifest.owner ) == 'table' then
                for t, pl in pairs( v.manifest.owner ) do
                    if helper.ok.sid64( pl ) and not table.HasValue( base.o, pl ) then
                        table.insert( base.o, pl )
                    end
                end
            end
        end

        return base.o
    end